import 'package:flutter/widgets.dart';

/// A [ChangeNotifier] that broadcasts navigation-enabled state changes so that
/// widgets can rebuild when navigation is toggled.
class TVNavigationController extends ChangeNotifier {
  bool _enabled = true;

  bool get enabled => _enabled;

  /// Enables or disables D-pad/arrow-key traversal globally.
  ///
  /// Widgets that observe this controller via [TVNavigationScope] will rebuild.
  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }
}

/// The low-level inherited widget that broadcasts changes to its subtree.
class TVNavigationScope extends InheritedNotifier<TVNavigationController> {
  const TVNavigationScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static TVNavigationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TVNavigationScope>()
        ?.notifier;
  }
}

/// A stateful manager wrapper that maintains a stable lifecycle for the
/// [TVNavigationController] when a custom controller is omitted.
class TVNavigation extends StatefulWidget {
  const TVNavigation({
    super.key,
    this.controller,
    required this.child,
  });

  final TVNavigationController? controller;
  final Widget child;

  @override
  State<TVNavigation> createState() => _TVNavigationState();
}

class _TVNavigationState extends State<TVNavigation> {
  TVNavigationController? _internalController;

  TVNavigationController get _effectiveController =>
      widget.controller ?? (_internalController ??= TVNavigationController());

  @override
  void didUpdateWidget(covariant TVNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null && widget.controller != null) {
        _internalController?.dispose();
        _internalController = null;
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TVNavigationScope(
      notifier: _effectiveController,
      child: widget.child,
    );
  }
}

/// Extension on [BuildContext] that exposes a concise TV-navigation API.
extension TVNavigationContext on BuildContext {
  // ── Focus control ────────────────────────────────────────────────────────

  /// Moves focus to [node].
  void tvRequestFocus(FocusNode node) => node.requestFocus();

  /// Removes focus from everything in the application.
  void tvClearFocus() => FocusManager.instance.primaryFocus?.unfocus();

  /// The [FocusNode] that currently holds primary focus, or `null` if nothing
  /// is focused.
  FocusNode? get tvFocusedNode => FocusManager.instance.primaryFocus;

  /// Returns `true` if [node] currently holds primary focus.
  bool tvIsFocused(FocusNode node) => node.hasPrimaryFocus;

  /// Returns `true` if any descendant of this widget's [Focus] scope has
  /// focus. Useful for highlighting a parent container when any child is active.
  bool get tvHasFocusWithin {
    final focusNode = Focus.maybeOf(this, scopeOk: true);
    return focusNode?.hasFocus ?? false;
  }

  /// Moves focus one step in [direction] using the focus traversal group 
  /// context belonging directly to the active node.
  bool tvFocusInDirection(TraversalDirection direction) {
    final node = FocusManager.instance.primaryFocus;
    final nodeContext = node?.context;
    if (node == null || nodeContext == null) return false;

    return FocusTraversalGroup.maybeOf(nodeContext)
            ?.inDirection(node, direction) ??
        false;
  }

  // ── Navigation enable / disable ──────────────────────────────────────────

  /// Returns `true` if TV D-pad navigation is currently enabled.
  bool get tvIsNavigationEnabled =>
      TVNavigationScope.maybeOf(this)?.enabled ?? true;

  /// Enables or disables D-pad/arrow-key traversal globally.
  void tvSetNavigationEnabled(bool enabled) =>
      TVNavigationScope.maybeOf(this)?.setEnabled(enabled);
}
