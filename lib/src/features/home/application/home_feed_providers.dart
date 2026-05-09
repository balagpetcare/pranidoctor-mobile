import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/config/app_config.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/home/application/home_startup_defer.dart';
import 'package:pranidoctor_mobile/src/features/home/data/mobile_app_config.dart';
import 'package:pranidoctor_mobile/src/features/home/data/service_category_item.dart';

Map<String, dynamic>? _unwrapDataMap(Object? data) {
  if (data is! Map<String, dynamic>) return null;
  if (data['ok'] != true) return null;
  final inner = data['data'];
  return inner is Map<String, dynamic> ? inner : null;
}

/// Service categories for home shortcuts (empty list on failure — not mock data).
final homeServiceCategoriesProvider =
    FutureProvider.autoDispose<List<ServiceCategoryItem>>((ref) async {
      await ref.watch(homeNetworkDeferProvider.future);
      final client = ref.watch(apiClientProvider);
      try {
        final res = await client
            .get('/api/mobile/service-categories')
            .timeout(const Duration(seconds: 18));
        final inner = _unwrapDataMap(res.data);
        if (inner == null) return [];
        final raw = inner['categories'];
        if (raw is! List<dynamic>) return [];
        return raw
            .whereType<Map<String, dynamic>>()
            .map(ServiceCategoryItem.fromJson)
            .where((c) => c.id.isNotEmpty && c.slug.isNotEmpty)
            .toList();
      } on DioException catch (e, st) {
        assert(() {
          debugPrint('homeServiceCategoriesProvider: $e\n$st');
          return true;
        }());
        return [];
      } catch (e, st) {
        assert(() {
          debugPrint('homeServiceCategoriesProvider: $e\n$st');
          return true;
        }());
        return [];
      }
    });

/// Server + dart-define emergency line (null when unset everywhere).
final mobileHomeAppConfigProvider = FutureProvider.autoDispose<MobileAppConfig>(
  (ref) async {
    await ref.watch(homeNetworkDeferProvider.future);
    final client = ref.watch(apiClientProvider);
    try {
      final res = await client
          .get('/api/mobile/app-config')
          .timeout(const Duration(seconds: 10));
      final inner = _unwrapDataMap(res.data);
      if (inner == null) return MobileAppConfig.empty;
      return MobileAppConfig.fromJson(inner);
    } on DioException catch (e, st) {
      assert(() {
        debugPrint('mobileHomeAppConfigProvider: $e\n$st');
        return true;
      }());
      return MobileAppConfig.empty;
    } catch (e, st) {
      assert(() {
        debugPrint('mobileHomeAppConfigProvider: $e\n$st');
        return true;
      }());
      return MobileAppConfig.empty;
    }
  },
);

/// Non-empty emergency phone: API value wins, else compile-time dart-define.
final effectiveEmergencyPhoneProvider = Provider.autoDispose<String?>((ref) {
  final asyncCfg = ref.watch(mobileHomeAppConfigProvider);
  final fromApi = asyncCfg.maybeWhen(
    data: (c) => c.emergencyPhone?.trim(),
    orElse: () => null,
  );
  if (fromApi != null && fromApi.isNotEmpty) return fromApi;
  final env = AppConfig.emergencyContactPhone.trim();
  return env.isEmpty ? null : env;
});
