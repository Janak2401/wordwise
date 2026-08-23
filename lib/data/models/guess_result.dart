enum LetterEvaluation {
  empty,
  tbd,
  absent,
  wrongPosition,
  correct,
}

class GuessLetter {
  final String char;
  final LetterEvaluation evaluation;

  const GuessLetter({
    required this.char,
    required this.evaluation,
  });

  GuessLetter copyWith({
    String? char,
    LetterEvaluation? evaluation,
  }) {
    return GuessLetter(
      char: char ?? this.char,
      evaluation: evaluation ?? this.evaluation,
    );
  }
}
