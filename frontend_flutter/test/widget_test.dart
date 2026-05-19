import 'package:flutter_test/flutter_test.dart';
import 'package:naddefli/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NaddefliApp());
    expect(find.byType(NaddefliApp), findsOneWidget);
  });
}
