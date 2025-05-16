# BadWordsModerator

`BadWordsModerator` is a Flutter widget that helps monitor and detect offensive words in user input fields. It automatically tracks all `EditableText` widgets (like `TextField` and `TextFormField`) within its child widget tree and triggers a callback whenever inappropriate words are detected.

## Features

- Detects bad words in real-time with debounce control.
- Customizable bad word detection logic.
- Callback when bad words are found.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  bad_words_moderator: ^0.2.0
````

## Usage

Wrap any part of your widget tree with `BadWordsModerator`:

```dart
import 'package:flutter/material.dart';
import 'package:bad_words_moderator/bad_words_moderator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BadWordsModerator(
          onDetected: (text) async {
            print("Bad words detected: $text");
          },
          controllers: [_controller],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(controller: _controller),
          ),
        ),
      ),
    );
  }
}
```

## Parameters

| Parameter    | Type                                     | Description                                                                     |
| ------------ | ---------------------------------------- | ------------------------------------------------------------------------------- |
| `child`      | `Widget`                                 | The widget that should be monitored.                                            |
| `controllers`| `List<TextEditingController>`            | Text controllers that shold be monitored.                                       |
| `onDetected` | `Future<void> Function(String text)`     | Callback triggered when bad words are detected.                                 |
| `detector`   | `Future<bool> Function(String, String?)` | Optional. Custom function to detect bad words (defaults to `badWordsDetector`). |
| `debounce`   | `Duration`                               | Optional. Time interval to debounce input changes (default: 300ms).             |

## Custom Detector

You can provide your own detector function:

```dart
Future<bool> myCustomDetector(String text, String? file) async {
  return text.contains("badword");
}
```

Then pass it to the widget:

```dart
BadWordsModerator(
  detector: myCustomDetector,
  onDetected: (text) async {
    // Handle detected bad word
  },
  child: MyWidgetTree(),
);
```

## Notes

* Internally, it uses a post-frame callback to traverse and monitor all `EditableText` widgets.
* Supports dynamic updates to inputs via `didChangeDependencies`.

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
