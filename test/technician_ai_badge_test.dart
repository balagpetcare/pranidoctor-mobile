import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pranidoctor_mobile/src/features/technician_ai/presentation/widgets/technician_ai_widgets.dart';

void main() {
  testWidgets('TechnicianAiBadge shows Bengali label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: TechnicianAiBadge())),
      ),
    );
    expect(find.textContaining('টেকনিশিয়ান'), findsOneWidget);
  });
}
