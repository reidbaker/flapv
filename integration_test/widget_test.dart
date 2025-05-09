import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flapv/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Golden Basic', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Click the Basic button and transition.
    expect(find.text('Basic'), findsOneWidget);
    await tester.tap(find.text('Basic'));
    await tester.pumpAndSettle();

    // Confirm we have navigated to the page.
    expect(find.text('Basic'), findsNothing);
    await expectLater(find.byType(MyApp), matchesGoldenFile('basic.png'));
  });
}
