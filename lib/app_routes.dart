import 'package:flutter/material.dart';

import 'models/note.dart';
import 'screens/note_detail_screen.dart';

abstract final class AppRoutes {
  static const detail = '/detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == detail) {
      // Nhận object được truyền qua arguments của Navigator.pushNamed.
      final note = settings.arguments as Note;
      return MaterialPageRoute<Note>(
        settings: settings,
        builder: (context) => NoteDetailScreen(note: note),
      );
    }
    return null;
  }
}
