import 'package:flutter/material.dart';

import '../models/note.dart';
import 'note_edit_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key, required this.note});

  final Note note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note _note;
  bool _hasSavedChanges = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  Future<void> _editNote() async {
    // Route trực tiếp: truyền dữ liệu bằng constructor thay vì named route.
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute<Note>(
        builder: (context) => NoteEditScreen(note: _note),
      ),
    );

    if (!mounted || updatedNote == null) return;

    setState(() {
      _note = updatedNote;
      _hasSavedChanges = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Đã lưu ghi chú')));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Note>(
      // Sau khi sửa, chặn maybePop mặc định để trả Note về danh sách.
      // Cách này xử lý cả Back trên AppBar và Back hệ thống.
      canPop: !_hasSavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _note);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Chi tiết ghi chú')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    _note.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nội dung',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_note.content, style: const TextStyle(height: 1.6)),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: _editNote,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Chỉnh sửa'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
