import 'package:flutter/services.dart';

Future<List<String>> loadWordList(String filename) async {
  final String content = await rootBundle.loadString(filename);
  final List<String> wordList =
      content
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
  return wordList;
}
