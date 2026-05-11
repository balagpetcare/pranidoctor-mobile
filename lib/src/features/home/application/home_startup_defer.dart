import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Completes after the first frame and a short pause so home-screen network work
/// does not compete with initial layout (reduces jank / VM disconnect on emulator).
///
/// Watch from providers: `await ref.watch(homeNetworkDeferProvider.future);`
final homeNetworkDeferProvider = FutureProvider<void>((ref) async {
  await WidgetsBinding.instance.endOfFrame;
  if (!ref.mounted) return;
  await Future<void>.delayed(const Duration(milliseconds: 48));
});
