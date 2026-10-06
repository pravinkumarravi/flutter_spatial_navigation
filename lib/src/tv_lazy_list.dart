import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spatial_navigation/src/tv_focusable.dart';

class TVLazyList extends StatefulWidget {
  const TVLazyList({
    super.key,
    required this.itemCount,
    required this.itemExtent,
    required this.itemBuilder,
    this.onSelect,
    this.scrollDirection = Axis.horizontal,
    this.focusAlignment = 0.0, // 0 = start keyline, 0.5 = centered
    this.padding = EdgeInsets.zero,
    this.duration = const Duration(milliseconds: 180),
    this.initialIndex = 0,
    this.controller,
    this.scrollCacheExtent,
    this.autofocus = false,
  });

  final int itemCount;
  final double itemExtent;
  final Widget Function(BuildContext context, int index, bool focused) itemBuilder;
  final void Function(int index)? onSelect;
  final Axis scrollDirection;
  final double focusAlignment;
  final EdgeInsets padding;
  final Duration duration;
  final int initialIndex;
  final ScrollController? controller;
  final ScrollCacheExtent? scrollCacheExtent;
  final bool autofocus;

  @override
  State<TVLazyList> createState() => _TVLazyListState();
}

class _TVLazyListState extends State<TVLazyList> {
  ScrollController? _internalScroll;
  ScrollController get _scroll => widget.controller ?? (_internalScroll ??= ScrollController());
  final _nodes = <int, FocusNode>{}; // only currently-built items
  late int _index;

  bool get _horizontal => widget.scrollDirection == Axis.horizontal;
  double get _padStart =>
      _horizontal ? widget.padding.left : widget.padding.top;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, math.max(0, widget.itemCount - 1));
    if (_index > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollTo(_index, jump: true);
      });
    }
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _requestWhenBuilt(_index);
      });
    }
  }

  void _register(int i, FocusNode n) => _nodes[i] = n;
  void _unregister(int i, FocusNode n) {
    if (_nodes[i] == n) _nodes.remove(i);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;

    final k = e.logicalKey;
    final isRtl = _horizontal && Directionality.of(context) == TextDirection.rtl;

    int delta = 0;
    if (_horizontal) {
      if (k == (isRtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)) {
        delta = 1;
      } else if (k == (isRtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft)) {
        delta = -1;
      }
    } else {
      if (k == LogicalKeyboardKey.arrowDown) {
        delta = 1;
      } else if (k == LogicalKeyboardKey.arrowUp) {
        delta = -1;
      }
    }
    if (delta == 0) return KeyEventResult.ignored;

    final next = _index + delta;
    if (next < 0 || next >= widget.itemCount) return KeyEventResult.ignored;

    final isRepeat = e is KeyRepeatEvent;
    focusIndex(next, isRepeat: isRepeat);
    return KeyEventResult.handled;
  }

  void focusIndex(int i, {bool isRepeat = false}) {
    _index = i;
    _scrollTo(i, isRepeat: isRepeat);
    _requestWhenBuilt(i);
  }

  void _scrollTo(int i, {bool jump = false, bool isRepeat = false}) {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final keylineSpace =
        pos.viewportDimension - _padStart - widget.itemExtent;
    final target = (i * widget.itemExtent - keylineSpace * widget.focusAlignment)
        .clamp(pos.minScrollExtent, pos.maxScrollExtent);

    if (jump) {
      _scroll.jumpTo(target);
    } else {
      final animDuration = isRepeat
          ? Duration(milliseconds: (widget.duration.inMilliseconds * 0.6).round())
          : widget.duration;
      _scroll.animateTo(target, duration: animDuration, curve: Curves.easeOut);
    }
  }

  void _requestWhenBuilt(int i, [int tries = 0]) {
    if (!mounted || _index != i) return;
    final node = _nodes[i];
    if (node != null && node.context != null && node.canRequestFocus) {
      node.requestFocus();
      return;
    }
    if (tries > 10) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _index != i) return;
      _requestWhenBuilt(i, tries + 1);
    });
  }

  @override
  void dispose() {
    _internalScroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        itemCount: widget.itemCount,
        itemExtent: widget.itemExtent,
        scrollCacheExtent: widget.scrollCacheExtent ?? ScrollCacheExtent.pixels(widget.itemExtent * 2),
        itemBuilder: (context, i) => _TVListItem(
          key: ValueKey(i),
          index: i,
          autofocus: widget.autofocus && i == _index,
          onCreate: _register,
          onDispose: _unregister,
          onFocused: (idx) => _index = idx,
          onSelect: widget.onSelect,
          builder: widget.itemBuilder,
        ),
      ),
    );
  }
}

class _TVListItem extends StatefulWidget {
  const _TVListItem({
    super.key,
    required this.index,
    required this.onCreate,
    required this.onDispose,
    required this.onFocused,
    required this.onSelect,
    required this.builder,
    this.autofocus = false,
  });

  final int index;
  final void Function(int, FocusNode) onCreate;
  final void Function(int, FocusNode) onDispose;
  final void Function(int) onFocused;
  final void Function(int)? onSelect;
  final Widget Function(BuildContext, int, bool) builder;
  final bool autofocus;

  @override
  State<_TVListItem> createState() => _TVListItemState();
}

class _TVListItemState extends State<_TVListItem> {
  late final FocusNode _node = FocusNode(debugLabel: 'tv_item_${widget.index}');

  @override
  void initState() {
    super.initState();
    widget.onCreate(widget.index, _node);
  }

  @override
  void dispose() {
    widget.onDispose(widget.index, _node);
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TVFocusable(
      focusNode: _node,
      autofocus: widget.autofocus,
      scrollOnFocus: false, // the list owns scrolling
      onFocusChange: (f) {
        if (f) widget.onFocused(widget.index);
      },
      onSelect: widget.onSelect == null
          ? null
          : () => widget.onSelect!(widget.index),
      builder: (ctx, focused) => widget.builder(ctx, widget.index, focused),
    );
  }
}