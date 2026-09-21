// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/widgets/category_chip.dart';

void main() {
  testWidgets('category chip renders and reports taps', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChip(
            label: 'Technology',
            isSelected: false,
            onTap: () => wasTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Technology'), findsOneWidget);

    await tester.tap(find.text('Technology'));
    await tester.pump();

    expect(wasTapped, isTrue);
  });
}
