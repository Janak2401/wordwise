import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/datasources/stats_store.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final played = StatsStore.totalPlayed;
    final won = StatsStore.totalWon;
    final winPercent = played > 0 ? ((won / played) * 100).toInt() : 0;
    final currentStreak = StatsStore.currentStreak;
    final maxStreak = StatsStore.maxStreak;
    final dist = StatsStore.guessDistribution;
    final maxCount = dist.fold<int>(0, (prev, element) => element > prev ? element : prev);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'STATISTICS',
          style: AppTypography.title.copyWith(letterSpacing: 2.0),
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
                _buildStatItem('$played', 'PLAYED'),
                _buildStatItem('$winPercent%', 'WIN %'),
                _buildStatItem('$currentStreak', 'STREAK'),
                _buildStatItem('$maxStreak', 'MAX'),
              ],
            ),

            const SizedBox(height: 36),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),

            // Guess Distribution Title
            Text(
              'GUESS DISTRIBUTION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.textPrimary,
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
                        style: const TextStyle(
                          color: AppColors.textSecondary,
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
                              color: AppColors.surface,
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
