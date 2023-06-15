import 'package:dfdaemonclient/app/app.dart';
import 'package:dfdaemonclient/route_list/route_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(RouteList), findsOneWidget);
    });
  });
}
