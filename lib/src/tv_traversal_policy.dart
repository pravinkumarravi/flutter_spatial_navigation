import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:flutter_spatial_navigation/src/tv_focus_group.dart';

/// What happens when D-pad navigation finds no candidate in a direction.
enum TVEdgeBehavior {
  /// Not handled: parent scopes or the system can react.
  escape,

  /// Consume the key and keep focus where it is.
  trap,
}

/// Android `FocusFinder`-style spatial traversal for D-pad navigation.
///
/// The candidate with the lowest `13 * major² + minor²` score wins, where
/// `major` is the gap along the movement axis and `minor` is the cross-axis
/// misalignment.
class TVSpatialTraversalPolicy extends FocusTraversalPolicy {
  const TVSpatialTraversalPolicy({
    this.edgeBehavior = TVEdgeBehavior.escape,
    super.requestFocusCallback = defaultTVRequestFocusCallback,
  });

  /// TV-friendly request focus callback that requests focus directly without
  /// triggering Flutter's mobile default [Scrollable.ensureVisible] (which centers
  /// items with alignment 0.5 and zero duration, causing row scroll offsets to reset).
  /// This allows TV components like [TVFocusable] and [TVLazyList] to manage their
  /// own keyline scrolling.
  static void defaultTVRequestFocusCallback(
    FocusNode node, {
    ScrollPositionAlignmentPolicy? alignmentPolicy,
    double? alignment,
    Duration? duration,
    Curve? curve,
  }) {
    node.requestFocus();
  }

  final TVEdgeBehavior edgeBehavior;

  static const double _majorWeight = 13;

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final scope = currentNode.nearestScope;
    if (scope == null) return false;

    final from = currentNode.rect;
    FocusNode? best;

    for (final candidate in scope.traversalDescendants) {
      if (identical(candidate, currentNode)) continue;
      if (!candidate.canRequestFocus || candidate.context == null) continue;
      if (_isBetterCandidate(from, candidate.rect, best?.rect, direction)) {
        best = candidate;
      }
    }

    if (best == null) return edgeBehavior == TVEdgeBehavior.trap;

    requestFocusCallback(
      TVFocusGroup.restoreTarget(entering: best, from: currentNode) ?? best,
    );
    return true;
  }

  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    return descendants.toList()
      ..sort((a, b) {
        final ra = a.rect;
        final rb = b.rect;
        // Tops closer than half the smaller height count as the same row.
        final sameRow =
            (ra.top - rb.top).abs() <= math.min(ra.height, rb.height) / 2;
        return sameRow ? ra.left.compareTo(rb.left) : ra.top.compareTo(rb.top);
      });
  }

  /// Picks the node nearest to the edge focus is coming from.
  @override
  FocusNode? findFirstFocusInDirection(
    FocusNode currentNode,
    TraversalDirection direction,
  ) {
    final scope =
        currentNode is FocusScopeNode ? currentNode : currentNode.nearestScope;
    if (scope == null) return null;

    FocusNode? best;
    for (final node in scope.traversalDescendants) {
      if (!node.canRequestFocus || node.context == null) continue;
      if (best == null || _entersBefore(node.rect, best.rect, direction)) {
        best = node;
      }
    }
    return best;
  }

  bool _isCandidate(Rect from, Rect to, TraversalDirection direction) {
    if (!_isAhead(from, to, direction)) return false;

    // In-beam candidates are always valid candidates.
    if (_isInBeam(from, to, direction)) return true;

    // Out-of-beam candidates must strictly progress along the movement axis
    // without overlapping on that axis.
    final majorRaw = _majorDistanceRaw(from, to, direction);
    if (majorRaw <= 0) return false;

    // Out-of-beam candidates must not deviate sideways more than their
    // progress along the movement axis (cone constraint).
    final gap = _crossAxisGap(from, to, direction);
    return majorRaw >= gap;
  }

  bool _isInBeam(Rect from, Rect to, TraversalDirection direction) {
    return _crossAxisGap(from, to, direction) == 0;
  }

  double _crossAxisGap(Rect from, Rect to, TraversalDirection direction) {
    final horizontal = direction == TraversalDirection.left ||
        direction == TraversalDirection.right;
    return horizontal
        ? _gap(from.top, from.bottom, to.top, to.bottom)
        : _gap(from.left, from.right, to.left, to.right);
  }

  bool _isBetterCandidate(
    Rect from,
    Rect candidate,
    Rect? best,
    TraversalDirection direction,
  ) {
    if (!_isCandidate(from, candidate, direction)) return false;
    if (best == null) return true;

    final candidateInBeam = _isInBeam(from, candidate, direction);
    final bestInBeam = _isInBeam(from, best, direction);

    // Android FocusFinder beamBeats: in-beam candidates always beat
    // out-of-beam candidates.
    if (candidateInBeam && !bestInBeam) return true;
    if (bestInBeam && !candidateInBeam) return false;

    final candidateScore = _score(from, candidate, direction);
    final bestScore = _score(from, best, direction);
    if (candidateScore == null) return false;
    if (bestScore == null) return true;

    return candidateScore < bestScore;
  }

  /// Returns null when [to] is not a valid candidate for [direction].
  double? _score(Rect from, Rect to, TraversalDirection direction) {
    if (!_isAhead(from, to, direction)) return null;

    final horizontal = direction == TraversalDirection.left ||
        direction == TraversalDirection.right;

    final gap = _crossAxisGap(from, to, direction);
    final centerOffset = horizontal
        ? (to.center.dy - from.center.dy).abs()
        : (to.center.dx - from.center.dx).abs();

    final major = _majorDistance(from, to, direction);
    final minor = gap + 0.5 * centerOffset;

    return _majorWeight * major * major + minor * minor;
  }

  bool _isAhead(Rect from, Rect to, TraversalDirection direction) {
    return switch (direction) {
      TraversalDirection.right =>
        to.center.dx > from.center.dx && to.right > from.right,
      TraversalDirection.left =>
        to.center.dx < from.center.dx && to.left < from.left,
      TraversalDirection.down =>
        to.center.dy > from.center.dy && to.bottom > from.bottom,
      TraversalDirection.up =>
        to.center.dy < from.center.dy && to.top < from.top,
    };
  }

  double _majorDistanceRaw(Rect from, Rect to, TraversalDirection direction) {
    return switch (direction) {
      TraversalDirection.right => to.left - from.right,
      TraversalDirection.left => from.left - to.right,
      TraversalDirection.down => to.top - from.bottom,
      TraversalDirection.up => from.top - to.bottom,
    };
  }

  double _majorDistance(Rect from, Rect to, TraversalDirection direction) {
    return math.max(0.0, _majorDistanceRaw(from, to, direction));
  }

  /// Distance between two 1-D ranges; 0 if they overlap.
  double _gap(double aStart, double aEnd, double bStart, double bEnd) {
    if (bStart >= aEnd) return bStart - aEnd;
    if (aStart >= bEnd) return aStart - bEnd;
    return 0;
  }

  /// True if [a] is a better entry point than [b].
  bool _entersBefore(Rect a, Rect b, TraversalDirection direction) {
    return switch (direction) {
      TraversalDirection.right =>
        a.left != b.left ? a.left < b.left : a.top < b.top,
      TraversalDirection.left =>
        a.right != b.right ? a.right > b.right : a.top < b.top,
      TraversalDirection.down =>
        a.top != b.top ? a.top < b.top : a.left < b.left,
      TraversalDirection.up =>
        a.bottom != b.bottom ? a.bottom > b.bottom : a.left < b.left,
    };
  }
}

/// Convenience short alias for [TVSpatialTraversalPolicy].
typedef TVTraversalPolicy = TVSpatialTraversalPolicy;
