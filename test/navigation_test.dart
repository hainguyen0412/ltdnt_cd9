import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_demo/app.dart';
import 'package:navigation_demo/app_routes.dart';
import 'package:navigation_demo/data/sample_notes.dart';
import 'package:navigation_demo/screens/note_detail_screen.dart';
import 'package:navigation_demo/screens/note_edit_screen.dart';
import 'package:navigation_demo/screens/note_list_screen.dart';

Future<void> openFirstNote(WidgetTester tester) async {
  await tester.pumpWidget(const NotesApp());
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('note-1')));
  await tester.pumpAndSettle();
}

Future<void> openEditor(WidgetTester tester) async {
  await tester.tap(find.text('Chỉnh sửa'));
  await tester.pumpAndSettle();
}

Future<void> toolbarBack(WidgetTester tester) async {
  // enterText không tự vẽ frame; cập nhật canPop trước thao tác Back.
  await tester.pump();
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> systemBack(WidgetTester tester) async {
  await tester.pump();
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Named route receives the selected note and returns unchanged', (
    tester,
  ) async {
    await openFirstNote(tester);

    final detail = tester.widget<NoteDetailScreen>(
      find.byType(NoteDetailScreen),
    );
    final route = ModalRoute.of(tester.element(find.byType(NoteDetailScreen)))!;
    expect(route.settings.name, AppRoutes.detail);
    expect(detail.note, same(sampleNotes.first));
    expect(find.text(sampleNotes.first.content), findsOneWidget);

    await toolbarBack(tester);
    expect(find.byType(NoteListScreen), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Saving updates detail, list and the next visit', (tester) async {
    await openFirstNote(tester);
    await openEditor(tester);

    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      '  Ghi chú đã sửa  ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('content-field')),
      'Nội dung mới để demo truyền dữ liệu.',
    );
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditScreen), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Ghi chú đã sửa'), findsOneWidget);
    expect(find.text('Đã lưu ghi chú'), findsOneWidget);

    await toolbarBack(tester);
    expect(find.text('Ghi chú đã sửa'), findsOneWidget);
    expect(find.text(sampleNotes[1].title), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('note-1')));
    await tester.pumpAndSettle();
    expect(find.text('Nội dung mới để demo truyền dữ liệu.'), findsOneWidget);
  });

  testWidgets('System Back returns the latest saved note to the list', (
    tester,
  ) async {
    await openFirstNote(tester);
    await openEditor(tester);
    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      'Đã lưu trước khi Back',
    );
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    await systemBack(tester);
    expect(find.byType(NoteListScreen), findsOneWidget);
    expect(find.byType(NoteDetailScreen), findsNothing);
    expect(find.text('Đã lưu trước khi Back'), findsOneWidget);
  });

  testWidgets('Toolbar Back can continue editing or discard the draft', (
    tester,
  ) async {
    await openFirstNote(tester);
    await openEditor(tester);
    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      'Bản nháp chưa lưu',
    );

    await toolbarBack(tester);
    expect(find.text('Bỏ thay đổi?'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục sửa'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteEditScreen), findsOneWidget);
    expect(find.text('Bản nháp chưa lưu'), findsOneWidget);

    await toolbarBack(tester);
    await tester.tap(find.text('Bỏ thay đổi'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteDetailScreen), findsOneWidget);
    expect(find.text(sampleNotes.first.title), findsOneWidget);
    expect(find.text('Bản nháp chưa lưu'), findsNothing);

    await toolbarBack(tester);
    expect(find.text(sampleNotes.first.title), findsOneWidget);
  });

  testWidgets('System Back discards only the draft, preserving earlier saves', (
    tester,
  ) async {
    await openFirstNote(tester);
    await openEditor(tester);
    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      'Phiên bản đã lưu',
    );
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      'Phiên bản chưa lưu',
    );
    await systemBack(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Bỏ thay đổi'));
    await tester.pumpAndSettle();
    expect(find.text('Phiên bản đã lưu'), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(NoteListScreen), findsOneWidget);
    expect(find.text('Phiên bản đã lưu'), findsOneWidget);
    expect(find.text('Phiên bản chưa lưu'), findsNothing);
  });

  testWidgets('Leaving an unchanged editor does not ask for confirmation', (
    tester,
  ) async {
    await openFirstNote(tester);
    await openEditor(tester);
    await systemBack(tester);

    expect(find.byType(NoteDetailScreen), findsOneWidget);
    expect(find.byType(NoteEditScreen), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(sampleNotes.first.title), findsOneWidget);
  });

  testWidgets('Blank title and content are rejected before navigating back', (
    tester,
  ) async {
    await openFirstNote(tester);
    await openEditor(tester);
    await tester.enterText(find.byKey(const ValueKey('title-field')), '   ');
    await tester.enterText(find.byKey(const ValueKey('content-field')), '');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditScreen), findsOneWidget);
    expect(find.text('Vui lòng nhập tiêu đề'), findsOneWidget);
    expect(find.text('Vui lòng nhập nội dung'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Small screens and larger text can scroll to Save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await openFirstNote(tester);
    await openEditor(tester);
    await tester.enterText(
      find.byKey(const ValueKey('content-field')),
      'Nội dung trên màn hình nhỏ.',
    );
    await tester.ensureVisible(find.text('Lưu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteDetailScreen), findsOneWidget);
    expect(find.text('Nội dung trên màn hình nhỏ.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
