import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/guess_result.dart';

class KeyboardKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final LetterEvaluation evaluation;
  final double flex;
  final Widget? customChild;

  const KeyboardKey({
    super.key,
    required this.label,
    required this.onTap,
    this.evaluation = LetterEvaluation.empty,
    this.flex = 1.0,
    this.customChild,
  });

  Color _getBackgroundColor() {
    switch (evaluation) {
      case LetterEvaluation.correct:
        return AppColors.correct;
      case LetterEvaluation.wrongPosition:
        return AppColors.wrongPosition;
      case LetterEvaluation.absent:
        return AppColors.absent;
      default:
        return AppColors.borderBright.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3.5),
        child: Material(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(4.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4.0),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              child: customChild ??
                  Text(
                    label,
                    style: AppTypography.keyLabel,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
