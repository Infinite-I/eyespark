import 'package:flutter_test/flutter_test.dart';
import 'package:assist_navigation_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Assist Navigation'), findsOneWidget);
  });
}