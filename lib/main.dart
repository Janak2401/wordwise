import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/dictionary_db.dart';
import 'data/datasources/game_state_store.dart';
import 'data/datasources/settings_store.dart';
import 'data/datasources/stats_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive key-value storage
  await Hive.initFlutter();
  await GameStateStore.init();
  await StatsStore.init();
  await SettingsStore.init();

  // Initialize SQLite dictionary database
  await DictionaryDatabase.instance.database;

  runApp(
    const ProviderScope(
      child: WordWiseApp(),
    ),
  );
}

class WordWiseApp extends StatelessWidget {
  const WordWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WordWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
