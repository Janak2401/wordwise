import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/datasources/settings_store.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Guess the Word',
      'body': 'Guess the hidden vocabulary word in 6 to 8 attempts. Tiles change color to give you clues.',
      'icon': '🧩',
    },
    {
      'title': 'Learn with Definitions',
      'body': 'Every puzzle gives you definition clues and audio pronunciations to reinforce vocabulary acquisition.',
      'icon': '🎓',
    },
    {
      'title': 'Build Your Word Bank',
      'body': 'Bookmark new words into your personal deck and track your daily streak of vocabulary mastery.',
      'icon': '📚',
    },
  ];

  void _finishOnboarding() {
    SettingsStore.setHasSeenOnboarding(true);
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('SKIP', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['icon']!, style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 32),
                        Text(
                          item['title']!,
                          style: AppTypography.title.copyWith(fontSize: 24, letterSpacing: 1.0),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['body']!,
                          style: AppTypography.bodySecondary.copyWith(fontSize: 16, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (idx) {
                  return Container(
                    width: _currentPage == idx ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == idx ? AppColors.correct : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.correct,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'GET STARTED' : 'CONTINUE',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
