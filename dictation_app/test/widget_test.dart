import 'package:flutter_test/flutter_test.dart';

import 'package:dictation_app/main.dart';

void main() {
  testWidgets('Dictation app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DictationApp());

    expect(find.text('字词听写'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('听写'), findsOneWidget);
  });
}
