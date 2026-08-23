import 'package:go_router/go_router.dart';
import '../../data/datasources/settings_store.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/word_bank/screens/word_bank_screen.dart';
import '../../features/stats/screens/stats_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/how_to_play/screens/how_to_play_screen.dart';

final appRouter = GoRouter(
  initialLocation: SettingsStore.hasSeenOnboarding ? '/game' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/word-bank',
      builder: (context, state) => const WordBankScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/how-to-play',
      builder: (context, state) => const HowToPlayScreen(),
    ),
  ],
);
