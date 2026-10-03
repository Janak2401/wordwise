import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/bookmarked_word.dart';
import '../../game/providers/game_provider.dart';
import '../../../core/theme/app_theme.dart';

final bookmarkedWordsProvider = FutureProvider.autoDispose<List<BookmarkedWord>>((ref) async {
  final repo = ref.watch(dictionaryRepoProvider);
  return repo.getBookmarkedWords();
});

class WordBankScreen extends ConsumerStatefulWidget {
  const WordBankScreen({super.key});

  @override
  ConsumerState<WordBankScreen> createState() => _WordBankScreenState();
}

class _WordBankScreenState extends ConsumerState<WordBankScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;
    final borderColor = palette.border;
    final surfaceColor = palette.surface;
    final bgColor = palette.background;

    final wordsAsync = ref.watch(bookmarkedWordsProvider);
    final tts = ref.watch(ttsProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textSecondary),
        title: Text(
          'WORD BANK',
          style: AppTypography.title.copyWith(letterSpacing: 2.0, color: textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search saved vocabulary...',
                hintStyle: AppTypography.bodySecondary.copyWith(color: textSecondary),
                prefixIcon: Icon(Icons.search, color: textSecondary),
                filled: true,
                fillColor: surfaceColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: wordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.correct)),
              error: (err, _) => Center(child: Text('Error: $err', style: AppTypography.bodySecondary.copyWith(color: textSecondary))),
              data: (words) {
                final filtered = words.where((bw) {
                  final w = bw.word?.word.toLowerCase() ?? '';
                  final d = bw.word?.definition.toLowerCase() ?? '';
                  return w.contains(_searchQuery) || d.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border_rounded, size: 64, color: palette.borderBright),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No words bookmarked yet.' : 'No matching words found.',
                            style: AppTypography.bodyRegular.copyWith(color: textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete daily puzzles and save words to build your personal vocabulary deck.',
                            style: AppTypography.bodySecondary.copyWith(color: textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bw = filtered[index];
                    final word = bw.word;
                    if (word == null) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    word.word,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (word.partOfSpeech != null)
                                    Text(
                                      '(${word.partOfSpeech})',
                                      style: AppTypography.bodyItalic.copyWith(fontSize: 12, color: textSecondary),
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.correct, size: 22),
                                    onPressed: () => tts.speak(word.word.toLowerCase()),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: textSecondary, size: 22),
                                    onPressed: () async {
                                      final repo = ref.read(dictionaryRepoProvider);
                                      await repo.removeBookmark(word.id);
                                      ref.invalidate(bookmarkedWordsProvider);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (word.phonetic != null)
                            Text(
                              word.phonetic!,
                              style: AppTypography.bodySecondary.copyWith(fontSize: 12, color: textSecondary),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            word.definition,
                            style: AppTypography.bodyRegular.copyWith(fontSize: 14, color: textPrimary),
                          ),
                          if (word.example != null && word.example!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '"${word.example}"',
                              style: AppTypography.bodyItalic.copyWith(fontSize: 13, color: textSecondary),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
