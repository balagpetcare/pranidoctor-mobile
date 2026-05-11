import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/enterprise_insights_providers.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/enterprise_media_upload_tick.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/media_upload_analytics_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/signed_upload_url_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/enterprise_media_upload_manager.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_image_pipeline.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_upload_activity_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_upload_queue_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_video_pipeline.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_task.dart';
import 'package:pranidoctor_mobile/src/features/uploads/application/upload_providers.dart';

final mediaUploadQueueStoreProvider = Provider<MediaUploadQueueStore>((ref) {
  return MediaUploadQueueStore();
});

final enterpriseMediaUploadManagerProvider =
    Provider<EnterpriseMediaUploadManager>((ref) {
  final manager = EnterpriseMediaUploadManager(
    uploadRepository: ref.watch(uploadRepositoryProvider),
    apiClient: ref.watch(apiClientProvider),
    connectivity: ref.watch(connectivityPortProvider),
    store: ref.watch(mediaUploadQueueStoreProvider),
    monitoring: ref.watch(monitoringPortProvider),
    signedUrlResolver: const NoOpSignedUploadUrlResolver(),
    analytics: const NoOpMediaUploadAnalytics(),
    imagePipeline: const MediaImagePipeline(),
    videoPipeline: const MediaVideoPipeline(),
    onTasksChanged: () {
      ref.read(enterpriseMediaUploadTickProvider.notifier).bump();
    },
  );
  ref.onDispose(manager.dispose);
  Future.microtask(() => manager.init());
  return manager;
});

final enterpriseMediaUploadTasksProvider =
    FutureProvider.autoDispose<List<MediaUploadTask>>((ref) async {
  ref.watch(enterpriseMediaUploadTickProvider);
  return ref.read(mediaUploadQueueStoreProvider).loadAll();
});

final enterpriseMediaUploadActivityProvider =
    FutureProvider.autoDispose<List<Map<String, Object?>>>((ref) async {
  ref.watch(enterpriseMediaUploadTickProvider);
  return loadMediaUploadActivity();
});
