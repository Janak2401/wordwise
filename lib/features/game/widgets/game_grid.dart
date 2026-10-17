import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/guess_result.dart';
import 'tile_row.dart';

class GameGrid extends StatelessWidget {
  final int wordLength;
  final int maxGuesses;
  final List<List<GuessLetter>> submittedRows;
  final String currentInput;
  final bool isShaking;
  final int? revealRow;

  const GameGrid({
    super.key,
    required this.wordLength,
    required this.maxGuesses,
    required this.submittedRows,
    required this.currentInput,
    this.isShaking = false,
    this.revealRow,
  });

  /// Largest square tile that lets [columns] x [rows] tiles fit in [space].
  static double tileSizeFor(Size space, int columns, int rows) {
    const gap = AppDimensions.tileGap;
    final byWidth = (space.width - gap * (columns - 1)) / columns;
    final byHeight = (space.height - gap * (rows - 1)) / rows;
    // Whole pixels, so rounding can never push the grid a fraction past its space.
    return min(byWidth, byHeight).clamp(0.0, AppDimensions.maxTileSize).floorToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = tileSizeFor(constraints.biggest, wordLength, maxGuesses);

        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimensions.tileGap,
          children: List.generate(maxGuesses, (rowIndex) {
            final isSubmitted = rowIndex < submittedRows.length;
            final isCurrent = rowIndex == submittedRows.length;

            return TileRow(
              length: wordLength,
              tileSize: tileSize,
              letters: isSubmitted ? submittedRows[rowIndex] : null,
              currentInput: isCurrent ? currentInput : null,
              isCurrentRow: isCurrent,
              isShaking: isCurrent && isShaking,
              animateReveal: rowIndex == revealRow,
            );
          }),
        );
      },
    );
  }
}
