import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';

class DefinitionHint extends StatelessWidget {
  final String? definition;
  final String? partOfSpeech;

  const DefinitionHint({
    super.key,
    this.definition,
    this.partOfSpeech,
  });

  @override
  Widget build(BuildContext context) {
    if (definition == null || definition!.isEmpty) {
      return const SizedBox(height: 32);
    }

    final posPrefix = partOfSpeech != null ? '$partOfSpeech. ' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Text(
        '"$posPrefix$definition"',
        style: AppTypography.bodyItalic,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
