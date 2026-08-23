import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/models/guess_result.dart';
import 'letter_tile.dart';

class TileRow extends StatefulWidget {
  final int length;
  final List<GuessLetter>? letters;
  final String? currentInput;
  final bool isCurrentRow;
  final bool isShaking;

  const TileRow({
    super.key,
    required this.length,
    this.letters,
    this.currentInput,
    this.isCurrentRow = false,
    this.isShaking = false,
  });

  @override
  State<TileRow> createState() => _TileRowState();
}

class _TileRowState extends State<TileRow> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(TileRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasLetters = widget.letters != null && widget.letters!.isNotEmpty;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = sin(_shakeAnimation.value * pi * 4) * 8 * (1 - _shakeAnimation.value);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              String char = '';
              LetterEvaluation eval = LetterEvaluation.empty;
              bool animate = false;

              if (hasLetters) {
                char = widget.letters![index].char;
                eval = widget.letters![index].evaluation;
                animate = true;
              } else if (widget.isCurrentRow && widget.currentInput != null) {
                if (index < widget.currentInput!.length) {
                  char = widget.currentInput![index];
                  eval = LetterEvaluation.tbd;
                }
              }

              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: LetterTile(
                      letter: char,
                      evaluation: eval,
                      index: index,
                      animateFlip: animate,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
