class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final bool isDeleted;
  final String? imageBase64;
  final String? mood;
  final bool isFavorite; // <--- NEW FIELD

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isDeleted = false,
    this.imageBase64,
    this.mood,
    this.isFavorite = false, // Default to false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'image_base64': imageBase64,
      'mood': mood,
      'isFavorite': isFavorite ? 1 : 0, // <--- SAVE
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      isDeleted: map['isDeleted'] == 1,
      imageBase64: map['image_base64'],
      mood: map['mood'],
      isFavorite: map['isFavorite'] == 1, // <--- LOAD
    );
  }
}
