import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';

void main() {
  testWidgets('moves focus right on a lazy list and scrolls', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FocusTraversalGroup(
        policy: TVTraversalPolicy(),
        child: SizedBox(
          height: 200,
          child: TVLazyList(
            itemCount: 100,
            itemExtent: 200,
            itemBuilder: (c, i, f) => Text('item $i${f ? " *" : ""}'),
          ),
        ),
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight); // enter list
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    expect(find.textContaining('*'), findsOneWidget);
  });
}