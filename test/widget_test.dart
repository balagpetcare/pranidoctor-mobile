import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/app/app.dart';

void main() {
  testWidgets('Prani Doctor app builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PraniDoctorApp(),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Prani Doctor'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 1600));
  });
}
