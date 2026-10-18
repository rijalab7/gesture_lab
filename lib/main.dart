// Gesture Lab - VERSION 2 (refined after testing)
//
// Gestures:
//   Tap the color card ......... changes the color and adds to the tap count
//   Long press the color card .. resets the card and shows a message
//   Swipe a task right ......... marks it done (the task stays in the list)
//   Swipe a task left .......... deletes it, with an Undo option
//   Refresh button (top bar) ... restores the task list
//
// What changed from Version 1:
//   1. Removed the double tap. It made every single tap wait about 300 ms,
//      because Flutter holds the tap to see if a second one is coming.
//   2. The card shrinks slightly while pressed, so there is instant feedback.
//   3. Long press now shows a message, so the reset is not silent.
//   4. Swipes do different things by direction, show a green "Done" or red
//      "Delete" background, have a hint line, and deleting offers Undo.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const GestureLabApp());

class GestureLabApp extends StatelessWidget {
  const GestureLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const GestureHomePage(),
    );
  }
}

class Task {
  Task(this.id, this.title);

  final int id;
  final String title;
  bool done = false;
}

List<Task> startingTasks() => [
      Task(1, 'Pack trail mix and snacks'),
      Task(2, 'Fill both water bottles'),
      Task(3, 'Charge the headlamp'),
      Task(4, 'Check the trail weather'),
      Task(5, 'Toss sunscreen in the bag'),
    ];

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

  static const Color _doneGreen = Color(0xFF43A047);
  static const Color _deleteRed = Color(0xFFE53935);

  int _colorIndex = 0;
  int _tapCount = 0;
  bool _pressed = false;
  String _lastGesture = 'None yet';
  String _tapResponse = '--';
  DateTime? _fingerUpTime;
  List<Task> _tasks = startingTasks();

  // ---------- Card gestures ----------

  void _onTap() {
    final ms = _fingerUpTime == null
        ? 0
        : DateTime.now().difference(_fingerUpTime!).inMilliseconds;
    setState(() {
      _tapCount++;
      _colorIndex = (_colorIndex + 1) % _colors.length;
      _lastGesture = 'Tap: color changed';
      _tapResponse = '$ms ms';
    });
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    setState(() {
      _tapCount = 0;
      _colorIndex = 0;
      _pressed = false;
      _lastGesture = 'Long press: card reset';
    });
    _showMessage('Card reset to the starting color');
  }

  // ---------- Task gestures ----------

  // Runs before a swipe finishes. A right swipe toggles "done" and returns
  // false so the task slides back instead of leaving the list.
  Future<bool> _confirmSwipe(DismissDirection direction, Task task) async {
    if (direction == DismissDirection.startToEnd) {
      HapticFeedback.selectionClick();
      setState(() {
        task.done = !task.done;
        _lastGesture =
            task.done ? 'Swipe right: marked done' : 'Swipe right: marked not done';
      });
      return false;
    }
    return true; // left swipe: let the delete happen
  }

  void _deleteTask(Task task) {
    final index = _tasks.indexOf(task);
    setState(() {
      _tasks.remove(task);
      _lastGesture = 'Swipe left: task deleted';
    });
    _showMessage(
      'Deleted "${task.title}"',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          setState(() {
            final at = index > _tasks.length ? _tasks.length : index;
            _tasks.insert(at, task);
            _lastGesture = 'Undo: task restored';
          });
        },
      ),
    );
  }

  void _resetTasks() {
    setState(() {
      _tasks = startingTasks();
      _lastGesture = 'Button tap: list restored';
    });
  }

  void _showMessage(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), action: action));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final cardColor = _colors[_colorIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Lab'),
        actions: [
          IconButton(
            tooltip: 'Restore task list',
            icon: const Icon(Icons.refresh),
            onPressed: _resetTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Shows the last gesture so every action is easy to see.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Last gesture: $_lastGesture',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Tap and long press card.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Listener(
              onPointerUp: (_) => _fingerUpTime = DateTime.now(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _pressed = true),
                onTapUp: (_) => setState(() => _pressed = false),
                onTapCancel: () => setState(() => _pressed = false),
                onTap: _onTap,
                onLongPress: _onLongPress,
                child: AnimatedScale(
                  scale: _pressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 170,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app, color: Colors.white, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          '$_tapCount ${_tapCount == 1 ? 'tap' : 'taps'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap to change color  •  Hold to reset',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Tap response: $_tapResponse'),
            ),
          ),

          // Hint for the hidden swipe gestures.
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.swipe, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Swipe right to complete, swipe left to delete'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Swipeable task list.
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('All tasks cleared. Tap refresh to restore.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Dismissible(
                        key: ValueKey(task.id),
                        background: _swipeBackground(
                            Icons.check, 'Done', _doneGreen, Alignment.centerLeft),
                        secondaryBackground: _swipeBackground(
                            Icons.delete, 'Delete', _deleteRed, Alignment.centerRight),
                        confirmDismiss: (direction) => _confirmSwipe(direction, task),
                        onDismissed: (_) => _deleteTask(task),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: task.done ? _doneGreen : null,
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Colored layer that shows behind a task while it is being swiped.
  Widget _swipeBackground(
      IconData icon, String label, Color color, Alignment alignment) {
    const labelStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    final iconWidget = Icon(icon, color: Colors.white);
    final textWidget = Text(label, style: labelStyle);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [iconWidget, const SizedBox(width: 8), textWidget]
            : [textWidget, const SizedBox(width: 8), iconWidget],
      ),
    );
  }
}