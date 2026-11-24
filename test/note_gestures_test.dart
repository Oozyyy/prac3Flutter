import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/main.dart';

void main() {
  testWidgets('Note gestures preserve the right note and its status', (
    tester,
  ) async {
    await tester.pumpWidget(const NotesApp());
    final editor = find.byType(TextField);
    const original = 'Полный текст\nСтрока 2\nСтрока 3\nСтрока 4';
    const edited = 'Изменённый текст';

    await tester.enterText(editor, original);
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    await tester.enterText(editor, 'Вторая заметка');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(original));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Заметка'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      original,
    );
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(original));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text(original));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.longPress(find.text(original));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(editor).controller?.text, original);

    await tester.drag(find.text('Вторая заметка'), const Offset(450, 0));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('Вторая заметка'), findsOneWidget);

    await tester.enterText(editor, edited);
    await tester.tap(find.text('Обновить'));
    await tester.pumpAndSettle();
    expect(find.text(edited), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.drag(find.text(edited), const Offset(450, 0));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.text(edited), findsOneWidget);

    await tester.drag(find.text(edited), const Offset(-450, 0));
    await tester.pumpAndSettle();
    expect(find.text(edited), findsNothing);
    expect(find.text('Вторая заметка'), findsOneWidget);
  });
}
