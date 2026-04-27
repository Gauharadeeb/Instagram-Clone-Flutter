import 'package:classico/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows instagram login page', (WidgetTester tester) async {
    await tester.pumpWidget(const ClassicoApp());

    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);
  });
}
