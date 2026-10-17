import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/dictionary_db.dart';
import 'data/datasources/game_state_store.dart';
import 'data/datasources/settings_store.dart';
import 'data/datasources/stats_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Hive key-value storage
  await Hive.initFlutter();
  await GameStateStore.init();
  await StatsStore.init();
  await SettingsStore.init();
  await _resetStaleLocalData();

  // Initialize SQLite dictionary database
  await DictionaryDatabase.instance.database;

  runApp(
    const ProviderScope(
      child: WordWiseApp(),
    ),
  );
}

/// Bump with the dictionary schema: word ids change on rebuild, so saved games and stats from
/// an older word list no longer line up.
const int _localDataVersion = 2;

Future<void> _resetStaleLocalData() async {
  if (SettingsStore.dataVersion >= _localDataVersion) return;
  await GameStateStore.box.clear();
  await StatsStore.box.clear();
  await SettingsStore.setDataVersion(_localDataVersion);
}

class WordWiseApp extends ConsumerWidget {
  const WordWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'WordWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
