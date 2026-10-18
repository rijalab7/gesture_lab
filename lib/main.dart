// Gesture Lab - VERSION 1 (before testing)
//
// Gestures:
//   Tap the color card ........ changes the color and adds to the tap count
//   Double tap the color card . adds or removes a star
//   Long press the color card . resets the card
//   Swipe a task (any way) .... deletes the task
//
// "Tap response" under the card shows how many milliseconds passed between
// lifting your finger and the app reacting to the tap.

import 'package:flutter/material.dart';

void main() => runApp(const GestureLabApp());

class GestureLabApp extends StatelessWidget {
  const GestureLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Lab v1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const GestureHomePage(),
    );
  }
}

class GestureHomePage extends StatefulWidget {
  const GestureHomePage({super.key});

  @override
  State<GestureHomePage> createState() => _GestureHomePageState();
}

class _GestureHomePageState extends State<GestureHomePage> {
  static const List<Color> _colors = [
    Color(0xFF3949AB), // indigo
    Color(0xFF00897B), // teal
    Color(0xFFF4511E), // orange
    Color(0xFF8E24AA), // purple
    Color(0xFF43A047), // green
  ];

  int _colorIndex = 0;
  int _tapCount = 0;
  bool _starred = false;
  String _lastGesture = 'None yet';
  String _tapResponse = '--';
  DateTime? _fingerUpTime;

  final List<String> _tasks = [
    'Pack trail mix and snacks',
    'Fill both water bottles',
    'Charge the headlamp',
    'Check the trail weather',
    'Toss sunscreen in the bag',
  ];

  void _onTap() {
    final ms = _fingerUpTime == null
        ? 0
        : DateTime.now().difference(_fingerUpTime!).inMilliseconds;
    setState(() {
      _tapCount++;
      _colorIndex = (_colorIndex + 1) % _colors.length;
      _lastGesture = 'Tap';
      _tapResponse = '$ms ms';
    });
  }

  void _onDoubleTap() {
    setState(() {
      _starred = !_starred;
      _lastGesture = 'Double tap';
    });
  }

  void _onLongPress() {
    setState(() {
      _tapCount = 0;
      _colorIndex = 0;
      _starred = false;
      _lastGesture = 'Long press';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gesture Lab (Version 1)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Last gesture: $_lastGesture',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          // Color card: tap, double tap, and long press.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Listener(
              onPointerUp: (_) => _fingerUpTime = DateTime.now(),
              child: GestureDetector(
                onTap: _onTap,
                onDoubleTap: _onDoubleTap,
                onLongPress: _onLongPress,
                child: Container(
                  height: 170,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: _colors[_colorIndex],
                  child: Text(
                    '${_starred ? '★ ' : ''}$_tapCount taps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Tap response: $_tapResponse'),
            ),
          ),
          const SizedBox(height: 8),

          // Task list: a swipe in either direction deletes the task.
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: ValueKey(task),
                  background: Container(color: Colors.red),
                  onDismissed: (_) {
                    setState(() {
                      _tasks.removeAt(index);
                      _lastGesture = 'Swipe';
                    });
                  },
                  child: ListTile(title: Text(task)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}