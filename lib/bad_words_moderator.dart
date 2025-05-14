import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bad_words_moderator/util/words_detector.dart';

class BadWordsModerator extends StatefulWidget {
  final Widget child;
  final String? wordListFile;
  final Future<bool> Function(String text, String? wordListFile) detector;
  final Future<void> Function(TextEditingController controller) onDetected;
  final Duration debounce;

  const BadWordsModerator({
    super.key,
    required this.child,
    required this.onDetected,
    this.wordListFile,
    this.detector = badWordsDetector,
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  State<BadWordsModerator> createState() => _BadWordsModeratorState();
}

class _BadWordsModeratorState extends State<BadWordsModerator> {
  final Map<TextEditingController, VoidCallback> _listeners = {};
  final Map<TextEditingController, Timer> _debounceTimers = {};
  final Map<TextEditingController, String> _lastValues = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupListener();
  }

  void _setupListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var entry in _listeners.entries) {
        entry.key.removeListener(entry.value);
      }
      _listeners.clear();
      _lastValues.clear();

      final editables = _findEditableTexts(context);
      for (final editable in editables) {
        final controller = editable.controller;

        void badWordsListener() {
          _debounceTimers[controller]?.cancel();
          _debounceTimers[controller] = Timer(widget.debounce, () async {
            final text = controller.text;
            if (text != _lastValues[controller]) {
              _lastValues[controller] = text;
              final hasBadWords =
                  await widget.detector(text, widget.wordListFile);
              if (hasBadWords) {
                await widget.onDetected(controller);
              }
            }
          });
        }

        final listener = badWordsListener;

        controller.addListener(listener);
        _listeners[controller] = listener;
        _lastValues[controller] = controller.text;
      }
    });
  }

  List<EditableText> _findEditableTexts(BuildContext context) {
    List<EditableText> editables = [];
    void visitor(Element element) {
      if (element.widget is EditableText) {
        editables.add(element.widget as EditableText);
      } else {
        element.visitChildren(visitor);
      }
    }

    context.visitChildElements(visitor);
    return editables;
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    for (var entry in _listeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _listeners.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
