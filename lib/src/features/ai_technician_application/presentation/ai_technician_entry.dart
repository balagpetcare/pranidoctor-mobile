import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_entry_screen.dart';

/// Profile entry: pushes resolver screen (loading → intro / wizard / status / dashboard).
Future<void> openAiTechnicianApplicationEntry(
  BuildContext context,
  WidgetRef _,
) async {
  try {
    await context.push(AiTechnicianApplicationEntryScreen.routePath);
  } catch (e, stack) {
    assert(() {
      debugPrint('openAiTechnicianApplicationEntry push failed: $e\n$stack');
      return true;
    }());
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.fixed,
            content: Text('এআই টেকনিশিয়ান আবেদন খুলতে পারিনি।'),
          ),
        );
    }
  }
}
