import 'wordlist.dart';

String normalize(String input) {
  return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

Future<bool> badWordsDetector(String text, String? wordListFile) async {
  final normalized = normalize(text);
  final wordList = await loadWordList(wordListFile ?? 'assets/wordlist.txt');
  return wordList.any((word) => normalized.contains(word));
}
