import 'package:go_router/go_router.dart';
import '../../data/datasources/settings_store.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/word_bank/screens/word_bank_screen.dart';
import '../../features/stats/screens/stats_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/how_to_play/screens/how_to_play_screen.dart';
import 'main_shell.dart';

final appRouter = GoRouter(
  initialLocation: SettingsStore.hasSeenOnboarding ? '/game' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Tabs: switching keeps each screen alive instead of stacking new copies.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/game',
            builder: (context, state) => const GameScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/word-bank',
            builder: (context, state) => const WordBankScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
        ]),
      ],
    ),
    // Pushed full-screen over the tabs.
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
