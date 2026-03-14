import 'package:flutter_test/flutter_test.dart';

import 'package:airxpert/main.dart';

void main() {
  testWidgets('AirXpert app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AirXpertRoot());

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('AirXpert'), findsWidgets);
  });
}
