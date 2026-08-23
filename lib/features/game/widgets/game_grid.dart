import 'package:flutter/material.dart';
import '../../../data/models/guess_result.dart';
import 'tile_row.dart';

class GameGrid extends StatelessWidget {
  final int wordLength;
  final int maxGuesses;
  final List<List<GuessLetter>> submittedRows;
  final String currentInput;
  final bool isShaking;

  const GameGrid({
    super.key,
    required this.wordLength,
    required this.maxGuesses,
    required this.submittedRows,
    required this.currentInput,
    this.isShaking = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxGuesses, (rowIndex) {
            final isSubmitted = rowIndex < submittedRows.length;
            final isCurrent = rowIndex == submittedRows.length;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: TileRow(
                length: wordLength,
                letters: isSubmitted ? submittedRows[rowIndex] : null,
                currentInput: isCurrent ? currentInput : null,
                isCurrentRow: isCurrent,
                isShaking: isCurrent && isShaking,
              ),
            );
          }),
        );
      },
    );
  }
}
