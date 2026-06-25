import 'package:flutter_test/flutter_test.dart';
import 'package:dirxplore3/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DirXploreApp());

    // Verify that we are on the browser tab.
    expect(find.text('http://172.16.50.4'), findsOneWidget);
  });
}
