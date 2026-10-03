import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/bookmarked_word.dart';
import '../../game/providers/game_provider.dart';

/// Saved words, newest first. Invalidate after adding or removing a bookmark.
final bookmarkedWordsProvider = FutureProvider.autoDispose<List<BookmarkedWord>>((ref) async {
  final repo = ref.watch(dictionaryRepoProvider);
  return repo.getBookmarkedWords();
});
