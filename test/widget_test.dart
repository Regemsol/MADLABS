import 'package:flutter_test/flutter_test.dart';

import 'package:madlabs/main.dart';

void main() {
  testWidgets('home page shows Mad Labs sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MadLabsApp());

    expect(find.text('Mad Labs'), findsWidgets);
    expect(find.text('Extensions'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });
}
