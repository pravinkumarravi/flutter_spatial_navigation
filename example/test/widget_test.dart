import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('TV App renders sidebar drawer, hero spotlight and carousel rows',
      (WidgetTester tester) async {
    // Provide a standard 1080p TV viewport for testing
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TVApp());
    await tester.pumpAndSettle();

    // Verify TV brand & collapsed rail
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tv_rounded), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    // Verify Hero Banner action buttons
    expect(find.text('Play Now'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);

    // Verify Carousel rows
    expect(find.text('Continue Watching'), findsOneWidget);
    expect(find.text('Top 10 Today'), findsOneWidget);
    expect(find.text('Blockbuster Movies'), findsOneWidget);

    // Autofocus activates 'Play Now'. Pressing select opens playback modal.
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    // Verify playback modal is open
    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text('Resume Playback'), findsOneWidget);

    // Close the playback modal via select
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(find.text('NOW PLAYING'), findsNothing);

    // Navigate down to carousel items
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    // Navigate right within carousel
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    // Navigate left back towards sidebar
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
  });
}
