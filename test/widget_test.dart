import 'package:flutter_test/flutter_test.dart';

import 'package:madlabs/main.dart';

void main() {
  testWidgets('home page shows food delivery UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MadLabsApp());

    expect(find.text('Deliver to'), findsOneWidget);
    expect(find.text('Popular categories'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);
  });
}
