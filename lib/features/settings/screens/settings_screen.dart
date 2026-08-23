import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/datasources/settings_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = SettingsStore.soundEnabled;
  bool _haptic = SettingsStore.hapticEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'SETTINGS',
          style: AppTypography.title.copyWith(letterSpacing: 2.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Sound Effects', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Play subtle sounds on actions', style: TextStyle(color: AppColors.textSecondary)),
            value: _sound,
            activeColor: AppColors.correct,
            onChanged: (val) {
              setState(() => _sound = val);
              SettingsStore.setSoundEnabled(val);
            },
          ),
          const Divider(color: AppColors.border),
          SwitchListTile(
            title: const Text('Haptic Feedback', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Vibrations on tile submit and key presses', style: TextStyle(color: AppColors.textSecondary)),
            value: _haptic,
            activeColor: AppColors.correct,
            onChanged: (val) {
              setState(() => _haptic = val);
              SettingsStore.setHapticEnabled(val);
            },
          ),
          const Divider(color: AppColors.border),
          ListTile(
            title: const Text('How to Play', style: TextStyle(color: AppColors.textPrimary)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
            onTap: () => context.push('/how-to-play'),
          ),
          const Divider(color: AppColors.border),
          ListTile(
            title: const Text('About WordWise', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('Version 1.0.0 (Minimal Ink)', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
