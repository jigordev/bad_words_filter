import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:bad_words_moderator/util/words_detector.dart';

class BadWordsModerator extends StatefulWidget {
  final Widget child;
  final List<TextEditingController> controllers;
  final String? wordListFile;
  final Future<bool> Function(String text, [String? wordListFile]) detector;
  final Future<void> Function(TextEditingController controller) onDetected;
  final Duration debounce;

  const BadWordsModerator({
    super.key,
    required this.child,
    required this.controllers,
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
  void initState() {
    super.initState();
    assert(
      widget.controllers.toSet().length == widget.controllers.length,
      'controllers list must not contain duplicates.',
    );
    _setupListeners();
  }

  @override
  void didUpdateWidget(covariant BadWordsModerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(
      widget.controllers.toSet().length == widget.controllers.length,
      'controllers list must not contain duplicates.',
    );
    if (!const ListEquality()
        .equals(oldWidget.controllers, widget.controllers)) {
      _clearListeners();
      _setupListeners();
    }
  }

  void _setupListeners() {
    for (var entry in _listeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _listeners.clear();
    _lastValues.clear();

    for (final controller in widget.controllers) {
      void listener() {
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

      controller.addListener(listener);
      _listeners[controller] = listener;
      _lastValues[controller] = controller.text;
    }
  }

  void _clearListeners() {
    _debounceTimers.values.forEach((timer) => timer.cancel());
    _debounceTimers.clear();

    _listeners.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listeners.clear();
    _lastValues.clear();
  }

  @override
  void dispose() {
    _clearListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
