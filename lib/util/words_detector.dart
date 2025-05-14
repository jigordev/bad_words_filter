import 'wordlist.dart';

Future<bool> badWordsDetector(String text, [String? wordListFile]) async {
  final wordList = await loadWordList(
    wordListFile ?? 'packages/bad_words_moderator/assets/wordlist.txt',
  );
  final normalizedWords = text
      .toLowerCase()
      .split(RegExp(r'[\s\W_]+'))
      .map((word) => word.replaceAll(RegExp(r'[^a-z0-9]'), ''))
      .where((word) => word.isNotEmpty);

  return normalizedWords.any((word) => wordList.contains(word));
}
