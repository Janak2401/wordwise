class Word {
  final int id;
  final String word;
  final int length;
  final String definition;
  final String? phonetic;
  final String? partOfSpeech;
  final String? example;
  final String? synonyms;
  final int difficulty;
  final String? category;

  const Word({
    required this.id,
    required this.word,
    required this.length,
    required this.definition,
    this.phonetic,
    this.partOfSpeech,
    this.example,
    this.synonyms,
    this.difficulty = 1,
    this.category = 'general',
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int,
      word: (map['word'] as String).toUpperCase(),
      length: map['length'] as int,
      definition: map['definition'] as String,
      phonetic: map['phonetic'] as String?,
      partOfSpeech: map['part_of_speech'] as String?,
      example: map['example'] as String?,
      synonyms: map['synonyms'] as String?,
      difficulty: map['difficulty'] as int? ?? 1,
      category: map['category'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'length': length,
      'definition': definition,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
      'example': example,
      'synonyms': synonyms,
      'difficulty': difficulty,
      'category': category,
    };
  }
}
