class Note {
  int? id;
  String title;
  String content;
  DateTime createdAt;
  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, createdAt: $createdAt}';
  }
}