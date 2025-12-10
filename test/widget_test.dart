import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:editor/main.dart';
import 'package:editor/models/editor_settings.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EditorApp());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('EditorOne'), findsWidgets);
  });

  testWidgets('Empty state shows action buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const EditorApp());
    await tester.pumpAndSettle();

    // Verify empty state buttons are shown
    expect(find.text('New File'), findsOneWidget);
    expect(find.text('Open File'), findsOneWidget);
    expect(find.text('Open Folder'), findsOneWidget);
  });

  testWidgets('Menu opens correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const EditorApp());
    await tester.pumpAndSettle();

    // Tap the menu button
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    // Verify menu items are shown
    expect(find.text('New File'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
  });

  test('EditorSettings serialization works correctly', () {
    const settings = EditorSettings(
      fontSize: 16.0,
      fontFamily: 'FiraCode',
      tabSize: 4,
    );

    final json = settings.toJson();
    final restored = EditorSettings.fromJson(json);

    expect(restored.fontSize, equals(16.0));
    expect(restored.fontFamily, equals('FiraCode'));
    expect(restored.tabSize, equals(4));
  });

  test('EditorSettings copyWith works correctly', () {
    const settings = EditorSettings();
    final updated = settings.copyWith(fontSize: 20.0, wordWrap: false);

    expect(updated.fontSize, equals(20.0));
    expect(updated.wordWrap, equals(false));
    expect(updated.fontFamily, equals(settings.fontFamily));
  });
}

