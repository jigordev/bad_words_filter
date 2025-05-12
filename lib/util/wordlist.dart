import 'package:flutter/services.dart';

List<String> defaultWordList = [
  "fuck",
  "shit",
  "bitch",
  "asshole",
  "bastard",
  "dick",
  "pussy",
  "faggot",
  "cunt",
  "nigger",
  "slut",
  "whore",
  "cock",
  "nigga",
  "motherfucker",
  "dildo",
  "bollocks",
  "wanker",
  "twat",
  "jerkoff",
  "jackoff",
  "prick",
  "cum",
  "rape",
  "rapist",
  "retard",
  "spastic",
  "shithead",
  "douche",
  "dipshit",
  "fag",
  "arsehole",
  "suckmydick",
  "fuckoff",
  "goddamn",
  "bastards",
  "cocksucker",
  "balllicker",
  "fuckedup",
  "shitfaced",
  "fuckface",
  "piss",
  "pissedoff",
  "bitchass",
  "crap",
  "buttfuck",
  "shitbag",
  "hoe",
  "skank",
  "tranny",
];

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
