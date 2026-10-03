import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/guess_result.dart';

class LetterTile extends StatefulWidget {
  final String letter;
  final LetterEvaluation evaluation;
  final int index;
  final bool animateFlip;

  const LetterTile({
    super.key,
    required this.letter,
    required this.evaluation,
    this.index = 0,
    this.animateFlip = false,
  });

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animateFlip) {
      Future.delayed(Duration(milliseconds: widget.index * 180), () {
        if (mounted) _controller.forward();
      });
    } else if (_isRevealed(widget.evaluation)) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateFlip && !oldWidget.animateFlip) {
      Future.delayed(Duration(milliseconds: widget.index * 180), () {
        if (mounted) _controller.forward(from: 0.0);
      });
    } else if (!widget.animateFlip) {
      // Restored or reset tiles snap to their final face without animating.
      _controller.value = _isRevealed(widget.evaluation) ? 1.0 : 0.0;
    }
  }

  static bool _isRevealed(LetterEvaluation evaluation) =>
      evaluation != LetterEvaluation.empty && evaluation != LetterEvaluation.tbd;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getFillColor(LetterEvaluation evaluation, bool isDark) {
    switch (evaluation) {
      case LetterEvaluation.correct:
        return AppColors.correct;
      case LetterEvaluation.wrongPosition:
        return AppColors.wrongPosition;
      case LetterEvaluation.absent:
        return isDark ? AppColors.absent : AppColors.keyAbsentLight;
      default:
        return Colors.transparent;
    }
  }

  Border _getBorder(LetterEvaluation evaluation, String letter, bool isDark) {
    if (evaluation == LetterEvaluation.correct ||
        evaluation == LetterEvaluation.wrongPosition ||
        evaluation == LetterEvaluation.absent) {
      return Border.all(color: Colors.transparent, width: 0);
    }
    final borderBright = isDark ? AppColors.borderBright : AppColors.lightBorderBright;
    final borderDefault = isDark ? AppColors.border : AppColors.lightBorder;

    if (letter.isNotEmpty) {
      return Border.all(color: borderBright, width: 2);
    }
    return Border.all(color: borderDefault, width: 2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final isUnder = angle > pi / 2;
        final textColor = (isUnder || isDark) ? Colors.white : AppColors.lightTextPrimary;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(angle),
          alignment: Alignment.center,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isUnder
                  ? _getFillColor(widget.evaluation, isDark)
                  : Colors.transparent,
              border: isUnder
                  ? Border.all(color: Colors.transparent, width: 0)
                  : _getBorder(widget.evaluation, widget.letter, isDark),
              borderRadius: BorderRadius.zero,
            ),
            child: Transform(
              transform: isUnder
                  ? (Matrix4.identity()..rotateX(pi))
                  : Matrix4.identity(),
              alignment: Alignment.center,
              child: Text(
                widget.letter,
                style: AppTypography.tileLetter.copyWith(color: textColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
