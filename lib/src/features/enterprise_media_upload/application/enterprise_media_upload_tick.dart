import 'package:flutter_riverpod/flutter_riverpod.dart';

final class EnterpriseMediaUploadTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final enterpriseMediaUploadTickProvider =
    NotifierProvider<EnterpriseMediaUploadTickNotifier, int>(
  EnterpriseMediaUploadTickNotifier.new,
);
