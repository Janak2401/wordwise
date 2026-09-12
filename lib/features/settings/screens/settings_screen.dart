import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../data/datasources/settings_store.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sound = SettingsStore.soundEnabled;
  bool _haptic = SettingsStore.hapticEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final textPrimary = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final bgColor = isDark ? AppColors.background : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textSecondary),
        title: Text(
          'SETTINGS',
          style: AppTypography.title.copyWith(letterSpacing: 2.0, color: textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Dark Theme', style: TextStyle(color: textPrimary)),
            subtitle: Text(
              isDark ? 'Dark mode is on' : 'Light mode is on',
              style: TextStyle(color: textSecondary),
            ),
            value: isDark,
            activeThumbColor: AppColors.correct,
            onChanged: (val) {
              ref.read(themeProvider.notifier).setTheme(val);
            },
          ),
          Divider(color: borderColor),
          SwitchListTile(
            title: Text('Sound Effects', style: TextStyle(color: textPrimary)),
            subtitle: Text('Play subtle sounds on actions', style: TextStyle(color: textSecondary)),
            value: _sound,
            activeThumbColor: AppColors.correct,
            onChanged: (val) {
              setState(() => _sound = val);
              SettingsStore.setSoundEnabled(val);
            },
          ),
          Divider(color: borderColor),
          SwitchListTile(
            title: Text('Haptic Feedback', style: TextStyle(color: textPrimary)),
            subtitle: Text('Vibrations on tile submit and key presses', style: TextStyle(color: textSecondary)),
            value: _haptic,
            activeThumbColor: AppColors.correct,
            onChanged: (val) {
              setState(() => _haptic = val);
              SettingsStore.setHapticEnabled(val);
            },
          ),
          Divider(color: borderColor),
          ListTile(
            title: Text('How to Play', style: TextStyle(color: textPrimary)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textSecondary),
            onTap: () => context.push('/how-to-play'),
          ),
          Divider(color: borderColor),
          ListTile(
            title: Text('About WordWise', style: TextStyle(color: textPrimary)),
            subtitle: Text('Version 1.1.0 (Minimal Ink)', style: TextStyle(color: textSecondary)),
          ),
        ],
      ),
    );
  }
}

