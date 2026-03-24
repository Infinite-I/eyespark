import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eyespark/main.dart';
import 'package:eyespark/providers/app_state.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const EyeSparkApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(EyeSparkApp), findsOneWidget);
  });
}