import 'word.dart';

class BookmarkedWord {
  final int id;
  final int wordId;
  final DateTime savedAt;
  final Word? word;

  const BookmarkedWord({
    required this.id,
    required this.wordId,
    required this.savedAt,
    this.word,
  });

  factory BookmarkedWord.fromMap(Map<String, dynamic> map, {Word? word}) {
    return BookmarkedWord(
      id: map['id'] as int,
      wordId: map['word_id'] as int,
      savedAt: DateTime.parse(map['saved_at'] as String),
      word: word,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word_id': wordId,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}
