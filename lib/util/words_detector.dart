import 'wordlist.dart';

Future<bool> badWordsDetector(String text, String? wordListFile) async {
  List<String> wordList =
      wordListFile != null ? await loadWordList(wordListFile) : defaultWordList;
  return wordList.any((word) => text.toLowerCase().contains(word));
}
