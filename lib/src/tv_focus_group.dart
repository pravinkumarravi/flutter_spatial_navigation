import 'package:flutter/widgets.dart';

final Expando<_TVFocusGroupState> _groups = Expando('TVFocusGroup');

class TVFocusGroup extends StatefulWidget {
  const TVFocusGroup({super.key, required this.child});
  final Widget child;

  /// Used by [TVTraversalPolicy]. Returns the remembered node if [entering]
  /// belongs to a different group than [from], otherwise null.
  static FocusNode? restoreTarget({
    required FocusNode entering,
    required FocusNode from,
  }) {
    final target = _enclosing(entering);
    if (target == null || target == _enclosing(from)) return null;
    final last = target.lastFocused;
    if (last == null) return null;
    try {
      if (last.context != null && last.canRequestFocus) {
        return last;
      }
    } catch (_) {
      target.lastFocused = null;
    }
    return null;
  }

  static _TVFocusGroupState? _enclosing(FocusNode node) {
    for (FocusNode? p = node; p != null; p = p.parent) {
      final group = _groups[p];
      if (group != null) return group;
    }
    return null;
  }

  @override
  State<TVFocusGroup> createState() => _TVFocusGroupState();
}

class _TVFocusGroupState extends State<TVFocusGroup> {
  final _node = FocusNode(
    debugLabel: 'TVFocusGroup',
    canRequestFocus: false,
    skipTraversal: true,
  );
  FocusNode? lastFocused;

  @override
  void initState() {
    super.initState();
    _groups[_node] = this;
  }

  @override
  void dispose() {
    _groups[_node] = null;
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<TVFocusNotification>(
      onNotification: (notification) {
        lastFocused = notification.node;
        return false; // allow bubbling to parent groups if nested
      },
      child: Focus(focusNode: _node, child: widget.child),
    );
  }
}

/// Dispatched when a focusable widget gains focus, allowing enclosing
/// [TVFocusGroup]s to record the focused descendant in real time.
class TVFocusNotification extends Notification {
  const TVFocusNotification(this.node);
  final FocusNode node;
}

/// Convenience alias for [TVFocusNotification].
typedef FocusNotification = TVFocusNotification;