import 'package:flutter_test/flutter_test.dart';
import 'package:gesture_lab/main.dart';

void main() {
  testWidgets('Tapping the card adds to the tap count', (tester) async {
    await tester.pumpWidget(const GestureLabApp());
    expect(find.text('0 taps'), findsOneWidget);

    await tester.tap(find.text('0 taps'));
    await tester.pumpAndSettle();

    expect(find.text('1 tap'), findsOneWidget);
    expect(find.text('Last gesture: Tap: color changed'), findsOneWidget);
  });
}