import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/app.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
