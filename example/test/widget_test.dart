import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('TV App renders sidebar drawer, hero spotlight and carousel rows',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TVApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tv_rounded), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    expect(find.text('Play Now'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);

    expect(find.text('Continue Watching'), findsOneWidget);
    expect(find.text('Top 10 Today'), findsOneWidget);
    expect(find.text('Blockbuster Movies'), findsOneWidget);

    // Autofocus activates 'Play Now'. Pressing select opens playback modal.
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text('Resume Playback'), findsOneWidget);

    // Close the playback modal via select
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(find.text('NOW PLAYING'), findsNothing);
  });

  testWidgets(
      'Pressing UP from leftmost card moves up to hero button, NOT to sidebar drawer',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TVApp());
    await tester.pumpAndSettle();

    final initialFocus = FocusManager.instance.primaryFocus!;

    // 1. Move DOWN from autofocus 'Play Now' into the first card of Continue Watching
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    final cardFocus = FocusManager.instance.primaryFocus!;
    expect(cardFocus.debugLabel, contains('tv_item_0'));

    // 2. Press UP from the leftmost card
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();

    final upFocus = FocusManager.instance.primaryFocus!;

    // Verify focus returned to Play Now above it, NOT the sidebar drawer!
    expect(upFocus.rect.left, equals(initialFocus.rect.left));
    expect(upFocus.debugLabel, isNot(contains('tv_item')));

    // 3. From Card 0, only pressing LEFT moves into the sidebar drawer
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // back to Card 0
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft); // navigate LEFT into drawer
    await tester.pumpAndSettle();

    final drawerFocus = FocusManager.instance.primaryFocus!;
    // Drawer is at the left edge
    expect(drawerFocus.rect.left, lessThanOrEqualTo(76.0));
  });
}
