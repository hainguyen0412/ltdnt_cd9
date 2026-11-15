import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/sample_notes.dart';
import '../models/note.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final List<Note> _notes = List.of(sampleNotes);

  Future<void> _openNote(Note note) async {
    // Named route: truyền dữ liệu đi và đợi dữ liệu trả về khi route đóng.
    final updatedNote = await Navigator.pushNamed<Note>(
      context,
      AppRoutes.detail,
      arguments: note,
    );

    if (!mounted || updatedNote == null) return;

    setState(() {
      final index = _notes.indexWhere((item) => item.id == updatedNote.id);
      _notes[index] = updatedNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ghi chú đơn giản')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Danh sách ghi chú',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('${_notes.length} ghi chú'),
                const SizedBox(height: 16),
                for (final note in _notes) ...[
                  ListTile(
                    key: ValueKey('note-${note.id}'),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: Text(note.title),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openNote(note),
                  ),
                  const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
