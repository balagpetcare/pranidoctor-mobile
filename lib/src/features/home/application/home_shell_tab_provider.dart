import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected tab index for [HomeShellScreen] (০–৪): হোম, ডাক্তার, সেবা, নোটিফিকেশন, প্রোফাইল.
/// Lets [HomeScreen] switch tabs without exposing shell internals.
final homeShellTabIndexProvider =
    NotifierProvider<HomeShellTabIndexNotifier, int>(
      HomeShellTabIndexNotifier.new,
    );

class HomeShellTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    if (index < 0 || index > 4) return;
    state = index;
  }
}
