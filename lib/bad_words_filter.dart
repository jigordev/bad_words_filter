import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bad_words_filter/util/words_detector.dart';

class BadWordsFilter extends StatefulWidget {
  final Widget child;
  final Future<bool> Function(String text, String? wordListFile) detector;
  final Future<void> Function(String text) onDetected;
  final Duration debounce;

  const BadWordsFilter({
    super.key,
    required this.child,
    required this.onDetected,
    this.detector = badWordsDetector,
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  State<BadWordsFilter> createState() => _BadWordsFilterState();
}

class _BadWordsFilterState extends State<BadWordsFilter> {
  TextEditingController? _controller;
  VoidCallback? _listener;
  Timer? _debounceTimer;
  String _lastValue = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupListener();
  }

  void _setupListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editable = _findEditableText(context);
      if (editable != null && editable.controller != _controller) {
        if (_controller != null && _listener != null) {
          _controller!.removeListener(_listener!);
        }

        _controller = editable.controller;
        _listener = () {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(widget.debounce, () async {
            final text = _controller!.text;
            if (text != _lastValue) {
              _lastValue = text;
              final hasBadWords = await widget.detector(text, null);
              if (hasBadWords) {
                await widget.onDetected(text);
              }
            }
          });
        };

        _controller!.addListener(_listener!);
      }
    });
  }

  EditableText? _findEditableText(BuildContext context) {
    EditableText? editable;
    void visitor(Element element) {
      if (element.widget is EditableText) {
        editable = element.widget as EditableText;
      } else {
        element.visitChildren(visitor);
      }
    }

    context.visitChildElements(visitor);
    return editable;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_controller != null && _listener != null) {
      _controller!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
