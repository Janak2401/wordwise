import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../providers/stats_provider.dart';
import '../../../core/theme/app_theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPalette.of(context);
    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;
    final borderColor = palette.border;
    final surfaceColor = isDark ? AppColors.surface : const Color(0xFFE5E7EB);
    final bgColor = palette.background;

    final stats = ref.watch(statsProvider);
    final played = stats.played;
    final winPercent = stats.winPercent;
    final currentStreak = stats.currentStreak;
    final maxStreak = stats.maxStreak;
    final dist = stats.guessDistribution;
    final maxCount = dist.fold<int>(0, (prev, element) => element > prev ? element : prev);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textSecondary),
        title: Text(
          'STATISTICS',
          style: AppTypography.title.copyWith(letterSpacing: 2.0, color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 4 Top Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('$played', 'PLAYED', textPrimary, textSecondary),
                _buildStatItem('$winPercent%', 'WIN %', textPrimary, textSecondary),
                _buildStatItem('$currentStreak', 'STREAK', textPrimary, textSecondary),
                _buildStatItem('$maxStreak', 'MAX', textPrimary, textSecondary),
              ],
            ),

            const SizedBox(height: 36),
            Divider(color: borderColor),
            const SizedBox(height: 24),

            // Guess Distribution Title
            Text(
              'GUESS DISTRIBUTION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Histogram Bars
            ...List.generate(dist.length, (index) {
              final guessNum = index + 1;
              final count = dist[index];
              final ratio = maxCount > 0 ? (count / maxCount) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      child: Text(
                        '$guessNum',
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: count > 0 ? ratio.clamp(0.1, 1.0) : 0.0,
                            child: Container(
                              height: 22,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: count > 0 ? AppColors.correct : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color primaryColor, Color secondaryColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}
