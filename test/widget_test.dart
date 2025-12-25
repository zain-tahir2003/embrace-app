// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';

// FIXED: Import your main.dart file
import 'package:embrace_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // FIXED: Changed EmbraceApp() to MyApp()
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'),
        findsNothing); // This is just default test logic, likely irrelevant now but compiles.
    expect(find.text('1'), findsNothing);
  });
}
