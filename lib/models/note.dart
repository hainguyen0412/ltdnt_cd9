class Note {
  const Note({required this.id, required this.title, required this.content});

  final int id;
  final String title;
  final String content;

  // Tạo bản mới để thao tác sửa chưa lưu không làm đổi dữ liệu gốc.
  Note copyWith({String? title, String? content}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
