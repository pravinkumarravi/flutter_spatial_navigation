import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spatial_navigation/src/tv_focus_group.dart';
import 'package:flutter_spatial_navigation/src/tv_navigation_context.dart';

class TVFocusable extends StatefulWidget {
  const TVFocusable({
    super.key,
    required this.builder,
    this.onSelect,
    this.onLongSelect,
    this.onFocusChange,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.scrollOnFocus = true,
    this.scrollAlignment = 0.5,
    this.targetUp,
    this.targetDown,
    this.targetLeft,
    this.targetRight,
    this.onKeyEvent,
  });

  final Widget Function(BuildContext context, bool focused) builder;
  final VoidCallback? onSelect;
  final VoidCallback? onLongSelect;
  final ValueChanged<bool>? onFocusChange;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  /// Set to false when a parent (e.g. [TVLazyList]) controls scrolling.
  final bool scrollOnFocus;
  final double scrollAlignment;

  /// Directional focus overrides, evaluated **at the moment the key is pressed**.
  ///
  /// Return a [FocusNode] to jump to that node, or `null` to trap (stay put).
  /// Leave a direction unset (`null` callback) to fall through to the automatic
  /// [TVSpatialTraversalPolicy] geometry calculation.
  ///
  /// Example — jump to sidebar only when it is visible:
  /// ```dart
  /// TVFocusable(
  ///   targetRight: () => isSidebarVisible ? sidebarNode : null,
  ///   builder: ...,
  /// )
  /// ```
  ///
  /// Example — static jump (node known at build time):
  /// ```dart
  /// TVFocusable(
  ///   targetRight: () => settingsNode,
  ///   builder: ...,
  /// )
  /// ```
  final FocusNode? Function()? targetUp;
  final FocusNode? Function()? targetDown;
  final FocusNode? Function()? targetLeft;
  final FocusNode? Function()? targetRight;
  final KeyEventResult Function(FocusNode node, KeyEvent event)? onKeyEvent;

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable> {
  FocusNode? _internalNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ??
      (_internalNode ??= FocusNode(debugLabel: 'TVFocusable'));

  bool _focused = false;
  Timer? _longPressTimer;
  bool _longPressed = false;

  static final _selectLogicalKeys = <LogicalKeyboardKey>{
    LogicalKeyboardKey.select,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
    LogicalKeyboardKey.gameButtonA,
    LogicalKeyboardKey.gameButtonSelect,
    LogicalKeyboardKey.space,
  };

  static final _selectPhysicalKeys = <PhysicalKeyboardKey>{
    PhysicalKeyboardKey.select,
    PhysicalKeyboardKey.enter,
    PhysicalKeyboardKey.numpadEnter,
    PhysicalKeyboardKey.gameButtonA,
    PhysicalKeyboardKey.space,
  };

  bool _isSelectKey(KeyEvent event) =>
      _selectLogicalKeys.contains(event.logicalKey) ||
      _selectPhysicalKeys.contains(event.physicalKey) ||
      event.logicalKey.keyId == 0x00100000017; // Android KEYCODE_DPAD_CENTER

  /// Returns the resolver for the pressed direction, or null if no override.
  FocusNode? Function()? _resolverFor(KeyEvent event) {
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowUp) return widget.targetUp;
    if (k == LogicalKeyboardKey.arrowDown) return widget.targetDown;
    if (k == LogicalKeyboardKey.arrowLeft) return widget.targetLeft;
    if (k == LogicalKeyboardKey.arrowRight) return widget.targetRight;
    return null;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _internalNode?.dispose();
    super.dispose();
  }

  void _handleFocus(bool value) {
    if (!mounted) return;
    if (!value) {
      _longPressTimer?.cancel();
      _longPressed = false;
    }
    setState(() => _focused = value);
    widget.onFocusChange?.call(value);
    if (value) {
      TVFocusNotification(_effectiveFocusNode).dispatch(context);
      if (widget.scrollOnFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_focused) return;
          final renderObject = context.findRenderObject();
          if (renderObject != null && renderObject.attached) {
            Scrollable.ensureVisible(
              context,
              alignment: widget.scrollAlignment,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;

    if (widget.onKeyEvent != null) {
      final res = widget.onKeyEvent!(node, event);
      if (res != KeyEventResult.ignored) return res;
    }

    // ── Directional overrides ──────────────────────────────────────────────
    // Only act on key-down / key-repeat to avoid double-firing.
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      // When navigation is globally disabled, consume arrow keys so the
      // spatial policy does not fire.
      if (!context.tvIsNavigationEnabled) {
        final k = event.logicalKey;
        if (k == LogicalKeyboardKey.arrowUp ||
            k == LogicalKeyboardKey.arrowDown ||
            k == LogicalKeyboardKey.arrowLeft ||
            k == LogicalKeyboardKey.arrowRight) {
          return KeyEventResult.handled;
        }
      }
      final resolver = _resolverFor(event);
      if (resolver != null) {
        // Resolver is set → we own this direction. Call it at press time.
        final target = resolver();
        if (target != null &&
            target.context != null &&
            target.canRequestFocus) {
          target.requestFocus();
        }
        // Return handled even when target is null (intentional trap).
        return KeyEventResult.handled;
      }
      // resolver == null → no override, fall through to spatial policy.
    }

    // ── Select / confirm keys ──────────────────────────────────────────────
    if (_isSelectKey(event)) {
      if (widget.onLongSelect == null) {
        if (event is KeyDownEvent && widget.onSelect != null) {
          widget.onSelect!();
        }
        return KeyEventResult.handled;
      }

      // When onLongSelect is provided, distinguish between tap and long press.
      if (event is KeyDownEvent) {
        _longPressed = false;
        _longPressTimer?.cancel();
        _longPressTimer = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _longPressed = true;
          widget.onLongSelect?.call();
        });
        return KeyEventResult.handled;
      } else if (event is KeyRepeatEvent) {
        return KeyEventResult.handled;
      } else if (event is KeyUpEvent) {
        _longPressTimer?.cancel();
        if (!_longPressed && widget.onSelect != null) {
          widget.onSelect!();
        }
        _longPressed = false;
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _effectiveFocusNode,
      autofocus: widget.autofocus,
      canRequestFocus: widget.enabled,
      skipTraversal: !widget.enabled,
      onFocusChange: _handleFocus,
      onKeyEvent: _handleKey,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onSelect : null,
        onLongPress: widget.enabled ? widget.onLongSelect : null,
        child: widget.builder(context, _focused),
      ),
    );
  }
}