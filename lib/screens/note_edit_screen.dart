import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteEditScreen extends StatefulWidget {
  const NoteEditScreen({super.key, required this.note});

  final Note note;

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isConfirming = false;

  bool get _hasChanges =>
      _titleController.text != widget.note.title ||
      _contentController.text != widget.note.content;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;

    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    // pop trực tiếp đóng route kèm kết quả, hoàn tất Future của push.
    Navigator.pop(context, updatedNote);
  }

  Future<void> _confirmDiscard() async {
    // Tránh mở nhiều hộp thoại nếu người dùng nhấn Back liên tục.
    if (_isConfirming) return;
    _isConfirming = true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bỏ thay đổi?'),
        content: const Text('Thay đổi chưa được lưu. Bạn muốn quay lại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tiếp tục sửa'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Bỏ thay đổi'),
          ),
        ],
      ),
    );

    _isConfirming = false;
    if (!mounted || discard != true) return;

    // Không trả kết quả: màn hình trước giữ dữ liệu đã lưu gần nhất.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Note>(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa ghi chú')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    TextFormField(
                      key: const ValueKey('title-field'),
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Tiêu đề'),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập tiêu đề'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('content-field'),
                      controller: _contentController,
                      decoration: const InputDecoration(labelText: 'Nội dung'),
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 6,
                      maxLines: 12,
                      onChanged: (_) => setState(() {}),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập nội dung'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: _saveNote,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Lưu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
