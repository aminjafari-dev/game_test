import 'package:flutter_test/flutter_test.dart';
import 'package:game_test/main.dart';

void main() {
  testWidgets('App launches with loading screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HorrorSurvivalApp());
    expect(find.text('Entering the building...'), findsOneWidget);
  });
}
