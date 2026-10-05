import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';

void main() {
  group('TVFocusable', () {
    testWidgets('triggers onSelect with dpadCenter, select, and enter keys',
        (tester) async {
      int selectCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TVFocusable(
            autofocus: true,
            onSelect: () => selectCount++,
            builder: (context, focused) => Text('Item (focused: $focused)'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Item (focused: true)'), findsOneWidget);

      // Test physical select
      await tester.sendKeyEvent(LogicalKeyboardKey.select,
          physicalKey: PhysicalKeyboardKey.select);
      await tester.pump();
      expect(selectCount, 1);

      // Test select
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pump();
      expect(selectCount, 2);

      // Test enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selectCount, 3);
    });

    testWidgets('triggers onLongSelect on key hold and tap on quick release',
        (tester) async {
      int selectCount = 0;
      int longSelectCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TVFocusable(
            autofocus: true,
            onSelect: () => selectCount++,
            onLongSelect: () => longSelectCount++,
            builder: (context, focused) => Text('Item (focused: $focused)'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Quick tap: key down then key up immediately
      await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(selectCount, 1);
      expect(longSelectCount, 0);

      // Long press: hold key down for > 500ms
      await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(milliseconds: 600));
      expect(longSelectCount, 1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      // selectCount should not have incremented on release of a long press
      expect(selectCount, 1);
    });

    testWidgets('respects enabled: false and cannot receive focus',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TVFocusable(
            autofocus: true,
            enabled: false,
            builder: (context, focused) => Text('Disabled (focused: $focused)'),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Disabled (focused: false)'), findsOneWidget);
    });
  });

  group('TVSpatialTraversalPolicy & TVFocusGroup', () {
    testWidgets('remembers last focused child when switching focus groups',
        (tester) async {
      final nodeA1 = FocusNode(debugLabel: 'A1');
      final nodeA2 = FocusNode(debugLabel: 'A2');
      final nodeB1 = FocusNode(debugLabel: 'B1');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FocusTraversalGroup(
            policy: const TVSpatialTraversalPolicy(),
            child: Column(
              children: [
                TVFocusGroup(
                  child: Row(
                    children: [
                      TVFocusable(
                        focusNode: nodeA1,
                        autofocus: true,
                        builder: (_, f) => const SizedBox(width: 50, height: 50),
                      ),
                      TVFocusable(
                        focusNode: nodeA2,
                        builder: (_, f) => const SizedBox(width: 50, height: 50),
                      ),
                    ],
                  ),
                ),
                TVFocusGroup(
                  child: Row(
                    children: [
                      TVFocusable(
                        focusNode: nodeB1,
                        builder: (_, f) => const SizedBox(width: 50, height: 50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(nodeA1.hasFocus, isTrue);

      // Move right to A2
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(nodeA2.hasFocus, isTrue);

      // Move down to B1
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(nodeB1.hasFocus, isTrue);

      // Move back up to Group A: should restore to A2, not A1!
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(nodeA2.hasFocus, isTrue);
    });
  });

  group('TVFocusable - Directional target overrides', () {
    testWidgets(
        'targetRight jumps to specified node instead of spatial neighbour',
        (tester) async {
      final nodeA = FocusNode(debugLabel: 'A');
      final nodeB = FocusNode(debugLabel: 'B');
      final nodeC = FocusNode(debugLabel: 'C');

      // Layout: [A] [B] [C]
      // A.targetRight = C  →  pressing RIGHT from A skips B and lands on C.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FocusTraversalGroup(
            policy: const TVSpatialTraversalPolicy(),
            child: Row(
              children: [
                TVFocusable(
                  focusNode: nodeA,
                  autofocus: true,
                  targetRight: () => nodeC, // override: skip B, go straight to C
                  builder: (_, f) => const SizedBox(width: 50, height: 50),
                ),
                TVFocusable(
                  focusNode: nodeB,
                  builder: (_, f) => const SizedBox(width: 50, height: 50),
                ),
                TVFocusable(
                  focusNode: nodeC,
                  builder: (_, f) => const SizedBox(width: 50, height: 50),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Should jump directly to C, not the spatially nearest B.
      expect(nodeC.hasFocus, isTrue);
      expect(nodeB.hasFocus, isFalse);
    });

    testWidgets(
        'targetLeft, targetUp, targetDown all jump to specified nodes',
        (tester) async {
      final nodeCenter = FocusNode(debugLabel: 'Center');
      final nodeUp = FocusNode(debugLabel: 'Up');
      final nodeDown = FocusNode(debugLabel: 'Down');
      final nodeLeft = FocusNode(debugLabel: 'Left');
      final nodeRight = FocusNode(debugLabel: 'Right');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FocusTraversalGroup(
            policy: const TVSpatialTraversalPolicy(),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                children: [
                  Positioned(
                    left: 125,
                    top: 0,
                    child: TVFocusable(
                      focusNode: nodeUp,
                      builder: (_, f) => const SizedBox(width: 50, height: 50),
                    ),
                  ),
                  Positioned(
                    left: 125,
                    top: 250,
                    child: TVFocusable(
                      focusNode: nodeDown,
                      builder: (_, f) => const SizedBox(width: 50, height: 50),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 125,
                    child: TVFocusable(
                      focusNode: nodeLeft,
                      builder: (_, f) => const SizedBox(width: 50, height: 50),
                    ),
                  ),
                  Positioned(
                    left: 250,
                    top: 125,
                    child: TVFocusable(
                      focusNode: nodeRight,
                      builder: (_, f) => const SizedBox(width: 50, height: 50),
                    ),
                  ),
                  Positioned(
                    left: 125,
                    top: 125,
                    child: TVFocusable(
                      focusNode: nodeCenter,
                      autofocus: true,
                      targetUp: () => nodeUp,
                      targetDown: () => nodeDown,
                      targetLeft: () => nodeLeft,
                      targetRight: () => nodeRight,
                      builder: (_, f) => const SizedBox(width: 50, height: 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(nodeCenter.hasFocus, isTrue);

      // UP
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(nodeUp.hasFocus, isTrue);

      // Back to center via DOWN
      nodeCenter.requestFocus();
      await tester.pumpAndSettle();

      // DOWN
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(nodeDown.hasFocus, isTrue);

      // Back to center
      nodeCenter.requestFocus();
      await tester.pumpAndSettle();

      // LEFT
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(nodeLeft.hasFocus, isTrue);

      // Back to center
      nodeCenter.requestFocus();
      await tester.pumpAndSettle();

      // RIGHT
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(nodeRight.hasFocus, isTrue);
    });

    testWidgets('null target falls through to spatial policy', (tester) async {
      final nodeA = FocusNode(debugLabel: 'A');
      final nodeB = FocusNode(debugLabel: 'B');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FocusTraversalGroup(
            policy: const TVSpatialTraversalPolicy(),
            child: Row(
              children: [
                TVFocusable(
                  focusNode: nodeA,
                  autofocus: true,
                  // No targetRight set → spatial policy takes over
                  builder: (_, f) => const SizedBox(width: 50, height: 50),
                ),
                TVFocusable(
                  focusNode: nodeB,
                  builder: (_, f) => const SizedBox(width: 50, height: 50),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isTrue);

      // With no targetRight, spatial policy should pick the nearest: B.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(nodeB.hasFocus, isTrue);
    });
  });

  group('TVNavigationContext extensions', () {
    testWidgets('tvRequestFocus moves focus to a specific node',
        (tester) async {
      final nodeA = FocusNode(debugLabel: 'A');
      final nodeB = FocusNode(debugLabel: 'B');
      late BuildContext savedContext;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            savedContext = context;
            return FocusTraversalGroup(
              policy: const TVSpatialTraversalPolicy(),
              child: Row(
                children: [
                  TVFocusable(
                    focusNode: nodeA,
                    autofocus: true,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                  TVFocusable(
                    focusNode: nodeB,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            );
          }),
        ),
      ));
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isTrue);

      savedContext.tvRequestFocus(nodeB);
      await tester.pumpAndSettle();
      expect(nodeB.hasFocus, isTrue);
    });

    testWidgets('tvClearFocus removes focus from everything', (tester) async {
      final nodeA = FocusNode(debugLabel: 'A');
      late BuildContext savedContext;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            savedContext = context;
            return FocusTraversalGroup(
              policy: const TVSpatialTraversalPolicy(),
              child: TVFocusable(
                focusNode: nodeA,
                autofocus: true,
                builder: (_, f) => const SizedBox(width: 50, height: 50),
              ),
            );
          }),
        ),
      ));
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isTrue);

      savedContext.tvClearFocus();
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isFalse);
    });

    testWidgets('tvFocusedNode and tvIsFocused return correct values',
        (tester) async {
      final nodeA = FocusNode(debugLabel: 'A');
      final nodeB = FocusNode(debugLabel: 'B');
      late BuildContext savedContext;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            savedContext = context;
            return FocusTraversalGroup(
              policy: const TVSpatialTraversalPolicy(),
              child: Row(
                children: [
                  TVFocusable(
                    focusNode: nodeA,
                    autofocus: true,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                  TVFocusable(
                    focusNode: nodeB,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            );
          }),
        ),
      ));
      await tester.pumpAndSettle();

      expect(savedContext.tvIsFocused(nodeA), isTrue);
      expect(savedContext.tvIsFocused(nodeB), isFalse);
      // tvFocusedNode returns the deepest primary-focused node; nodeA should
      // be in the chain.
      expect(savedContext.tvFocusedNode, isNotNull);
    });

    testWidgets(
        'tvSetNavigationEnabled(false) blocks arrow key traversal',
        (tester) async {
      final controller = TVNavigationController();
      final nodeA = FocusNode(debugLabel: 'A');
      final nodeB = FocusNode(debugLabel: 'B');

      await tester.pumpWidget(MaterialApp(
        home: TVNavigation(
          controller: controller,
          child: Scaffold(
            body: FocusTraversalGroup(
              policy: const TVSpatialTraversalPolicy(),
              child: Row(
                children: [
                  TVFocusable(
                    focusNode: nodeA,
                    autofocus: true,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                  TVFocusable(
                    focusNode: nodeB,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isTrue);

      // Disable navigation
      controller.setEnabled(false);
      await tester.pumpAndSettle();

      // Arrow right should be trapped — focus stays on A
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isTrue);
      expect(nodeB.hasFocus, isFalse);

      // Re-enable navigation
      controller.setEnabled(true);
      await tester.pumpAndSettle();

      // Now arrow right should work
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(nodeB.hasFocus, isTrue);
    });

    testWidgets('TVFocusNotification dispatches and updates TVFocusGroup in real time',
        (tester) async {
      final node1 = FocusNode(debugLabel: 'Item1');
      final node2 = FocusNode(debugLabel: 'Item2');
      final nodeOutside = FocusNode(debugLabel: 'Outside');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TVFocusGroup(
                child: Row(
                  children: [
                    TVFocusable(
                      focusNode: node1,
                      autofocus: true,
                      builder: (_, f) => const SizedBox(width: 50, height: 50),
                    ),
                    TVFocusable(
                      focusNode: node2,
                      builder: (_, f) => const SizedBox(width: 50, height: 50),
                    ),
                  ],
                ),
              ),
              TVFocusable(
                focusNode: nodeOutside,
                builder: (_, f) => const SizedBox(width: 50, height: 50),
              ),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(node1.hasFocus, isTrue);

      // Move to node2
      node2.requestFocus();
      await tester.pumpAndSettle();
      expect(node2.hasFocus, isTrue);

      // Now move outside the group
      nodeOutside.requestFocus();
      await tester.pumpAndSettle();
      expect(nodeOutside.hasFocus, isTrue);

      // restoreTarget when entering from outside should return node2!
      final restored = TVFocusGroup.restoreTarget(entering: node1, from: nodeOutside);
      expect(restored, equals(node2));
    });

    testWidgets('TVNavigation creates and preserves internal controller across rebuilds',
        (tester) async {
      late BuildContext capturedContext;
      int buildCount = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            buildCount++;
            return TVNavigation(
              child: MaterialApp(
                home: Scaffold(
                  body: Builder(builder: (ctx) {
                    capturedContext = ctx;
                    return TextButton(
                      onPressed: () => setState(() {}),
                      child: Text('Rebuild $buildCount'),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      );

      final initialController = TVNavigationScope.maybeOf(capturedContext);
      expect(initialController, isNotNull);
      expect(capturedContext.tvIsNavigationEnabled, isTrue);

      // Trigger rebuild of parent
      await tester.tap(find.text('Rebuild 1'));
      await tester.pumpAndSettle();

      final recheckedController = TVNavigationScope.maybeOf(capturedContext);
      // Controller must be the identical instance across rebuilds!
      expect(identical(initialController, recheckedController), isTrue);

      capturedContext.tvSetNavigationEnabled(false);
      expect(capturedContext.tvIsNavigationEnabled, isFalse);
    });

    testWidgets(
        'tvFocusInDirection resolves traversal group from focused node context even when called outside',
        (tester) async {
      late BuildContext outsideContext;
      final nodeA = FocusNode(debugLabel: 'A');
      final nodeB = FocusNode(debugLabel: 'B');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            outsideContext = context;
            return FocusTraversalGroup(
              policy: const TVSpatialTraversalPolicy(),
              child: Row(
                children: [
                  TVFocusable(
                    focusNode: nodeA,
                    autofocus: true,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                  TVFocusable(
                    focusNode: nodeB,
                    builder: (_, f) => const SizedBox(width: 50, height: 50),
                  ),
                ],
              ),
            );
          }),
        ),
      ));
      await tester.pumpAndSettle();
      expect(nodeA.hasFocus, isTrue);

      // Calling tvFocusInDirection from outsideContext (which has no FocusTraversalGroup above it):
      final moved = outsideContext.tvFocusInDirection(TraversalDirection.right);
      await tester.pumpAndSettle();

      expect(moved, isTrue);
      expect(nodeB.hasFocus, isTrue);
    });
  });
}
