import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notesapp/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
