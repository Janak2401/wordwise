import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/datasources/settings_store.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _haptic = SettingsStore.hapticEnabled;
  final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final palette = AppPalette.of(context);
    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;
    final borderColor = palette.border;
    final bgColor = palette.background;

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
            title: Text('Haptic Feedback', style: TextStyle(color: textPrimary)),
            subtitle: Text('Vibrations on tile submit and key presses', style: TextStyle(color: textSecondary)),
            value: _haptic,
            activeThumbColor: AppColors.correct,
            onChanged: (val) async {
              setState(() => _haptic = val);
              await SettingsStore.setHapticEnabled(val);
              // Confirms the setting took effect when switching it on.
              HapticUtils.selection();
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
            subtitle: FutureBuilder<PackageInfo>(
              future: _packageInfo,
              builder: (context, snapshot) {
                final info = snapshot.data;
                return Text(
                  info == null ? 'Version …' : 'Version ${info.version} (${info.buildNumber})',
                  style: TextStyle(color: textSecondary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

