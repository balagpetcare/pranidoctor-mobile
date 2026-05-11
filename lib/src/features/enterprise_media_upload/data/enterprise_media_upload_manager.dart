import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/connectivity_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/offline_sync_monitoring_ports.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_insights/application/sync_backoff.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/media_upload_analytics_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/application/signed_upload_url_port.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_file_integrity.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_image_pipeline.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_mime.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_upload_activity_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_upload_queue_store.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/data/media_video_pipeline.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/chunk_upload_plan.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_kind.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_lifecycle.dart';
import 'package:pranidoctor_mobile/src/features/enterprise_media_upload/domain/media_upload_task.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/uploads/data/upload_repository.dart';

class EnterpriseMediaEnqueueRequest {
  const EnterpriseMediaEnqueueRequest({
    required this.kind,
    required this.purpose,
    required this.sourcePath,
    required this.displayName,
  });

  final MediaUploadKind kind;
  final String purpose;
  final String sourcePath;
  final String displayName;
}

/// Central orchestrator: queue, compression, integrity hash, multipart upload,
/// signed-URL PUT path, retry/backoff, cancel/pause/resume.
class EnterpriseMediaUploadManager {
  EnterpriseMediaUploadManager({
    required UploadRepository uploadRepository,
    required ApiClient apiClient,
    required ConnectivityPort connectivity,
    required MediaUploadQueueStore store,
    required MonitoringPort monitoring,
    required SignedUploadUrlResolver signedUrlResolver,
    required MediaUploadAnalyticsPort analytics,
    required MediaImagePipeline imagePipeline,
    required MediaVideoPipeline videoPipeline,
    required void Function() onTasksChanged,
  })  : _uploads = uploadRepository,
        _api = apiClient,
        _connectivity = connectivity,
        _store = store,
        _monitoring = monitoring,
        _signed = signedUrlResolver,
        _analytics = analytics,
        _image = imagePipeline,
        _video = videoPipeline,
        _onTasksChanged = onTasksChanged;

  final UploadRepository _uploads;
  final ApiClient _api;
  final ConnectivityPort _connectivity;
  final MediaUploadQueueStore _store;
  final MonitoringPort _monitoring;
  final SignedUploadUrlResolver _signed;
  final MediaUploadAnalyticsPort _analytics;
  final MediaImagePipeline _image;
  final MediaVideoPipeline _video;
  final void Function() _onTasksChanged;

  final Random _rand = Random.secure();
  Future<void> _chain = Future<void>.value();
  final Map<String, CancelToken> _cancelTokens = {};
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  CancelToken _tokenFor(String id) =>
      _cancelTokens.putIfAbsent(id, CancelToken.new);

  Future<T> _serial<T>(Future<T> Function() fn) {
    final c = Completer<T>();
    _chain = _chain.then((_) async {
      try {
        c.complete(await fn());
      } catch (e, st) {
        c.completeError(e, st);
        _monitoring.captureException(e, st);
      }
    });
    return c.future;
  }

  Future<void> init() async {
    await _connSub?.cancel();
    _connSub = _connectivity.onConnectivityChanged.listen((_) {
      _monitoring.breadcrumb('media_upload.connectivity');
      unawaited(processQueue());
    });
  }

  void dispose() {
    unawaited(_connSub?.cancel());
    _connSub = null;
    for (final t in _cancelTokens.values) {
      t.cancel('dispose');
    }
    _cancelTokens.clear();
  }

  Future<void> _patch(String id, MediaUploadTask Function(MediaUploadTask t) fn) async {
    final list = await _store.loadAll();
    final i = list.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final next = fn(list[i]);
    list[i] = next;
    await _store.saveAll(list);
    _analytics.recordLifecycle(
      taskId: id,
      lifecycle: next.lifecycle,
      progress: next.progress,
    );
  }

  Future<String> enqueue(EnterpriseMediaEnqueueRequest r) {
    return _serial(() async {
      final src = File(r.sourcePath);
      if (!src.existsSync()) {
        throw StateError('missing_source_file');
      }
      final now = DateTime.now().toUtc();
      final id =
          'mu_${now.millisecondsSinceEpoch}_${_rand.nextInt(1 << 30)}';
      final mime = guessMimeTypeFromPath(r.sourcePath);
      final task = MediaUploadTask(
        id: id,
        kind: r.kind,
        purpose: r.purpose,
        sourcePath: r.sourcePath,
        displayName: r.displayName,
        mimeType: mime,
        lifecycle: MediaUploadLifecycle.queued,
        progress: 0,
        retryCount: 0,
        createdAtUtc: now,
        updatedAtUtc: now,
        sizeBytesOriginal: src.lengthSync(),
      );
      final list = await _store.loadAll();
      list.add(task);
      await _store.saveAll(list);
      _analytics.recordEnqueue(taskId: id, kind: r.kind, purpose: r.purpose);
      await appendMediaUploadActivity(
        titleBn: 'মিডিয়া কিউতে যোগ',
        detailBn: r.displayName,
      );
      _onTasksChanged();
      unawaited(processQueue());
      return id;
    });
  }

  Future<void> cancel(String taskId) {
    return _serial(() async {
      _cancelTokens[taskId]?.cancel('user_cancel');
      final list = await _store.loadAll();
      final i = list.indexWhere((e) => e.id == taskId);
      if (i < 0) return;
      final t = list[i];
      await _store.deleteTempArtifacts(t);
      list[i] = t.copyWith(
        lifecycle: MediaUploadLifecycle.failed,
        lastError: 'cancelled',
        progress: 0,
        updatedAtUtc: DateTime.now().toUtc(),
      );
      await _store.saveAll(list);
      _analytics.recordTerminal(taskId: taskId, success: false, errorCode: 'cancelled');
      _onTasksChanged();
    });
  }

  Future<void> pause(String taskId) {
    return _serial(() async {
      _cancelTokens[taskId]?.cancel('pause');
      await _patch(
        taskId,
        (t) => t.copyWith(
          paused: true,
          updatedAtUtc: DateTime.now().toUtc(),
        ),
      );
      _onTasksChanged();
    });
  }

  Future<void> resume(String taskId) {
    return _serial(() async {
      await _patch(
        taskId,
        (t) => t.copyWith(
          paused: false,
          updatedAtUtc: DateTime.now().toUtc(),
        ),
      );
      _onTasksChanged();
      unawaited(processQueue());
    });
  }

  Future<void> retry(String taskId) {
    return _serial(() async {
      await _patch(
        taskId,
        (t) => t.copyWith(
          lifecycle: MediaUploadLifecycle.queued,
          retryCount: 0,
          progress: 0,
          clearError: true,
          clearNextAttempt: true,
          updatedAtUtc: DateTime.now().toUtc(),
        ),
      );
      _onTasksChanged();
      unawaited(processQueue());
    });
  }

  Future<void> processQueue() {
    return _serial(() async {
      for (var n = 0; n < 32; n++) {
        if (!await _connectivity.isConnected) return;
        final list = await _store.loadAll();
        final id = _pickRunnableId(list);
        if (id == null) return;
        await _driveTask(id);
        _onTasksChanged();
      }
    });
  }

  String? _pickRunnableId(List<MediaUploadTask> list) {
    final now = DateTime.now().toUtc();
    MediaUploadTask? best;
    for (final t in list) {
      if (t.paused) continue;
      if (t.lifecycle == MediaUploadLifecycle.completed ||
          t.lifecycle == MediaUploadLifecycle.failed) {
        continue;
      }
      if (t.lifecycle == MediaUploadLifecycle.retryScheduled) {
        final na = t.nextAttemptUtc;
        if (na != null && na.isAfter(now)) continue;
      }
      if (best == null || t.createdAtUtc.isBefore(best.createdAtUtc)) {
        best = t;
      }
    }
    return best?.id;
  }

  Future<void> _fail(
    String id,
    String message, {
    required bool retryable,
  }) async {
    final list = await _store.loadAll();
    final i = list.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final t = list[i];
    final now = DateTime.now().toUtc();
    if (retryable && t.retryCount < SyncBackoff.maxRetries) {
      final nextRetry = t.retryCount + 1;
      final na = SyncBackoff.nextAttemptAfter(
        nowUtc: now,
        zeroBasedRetryCount: t.retryCount,
      );
      list[i] = t.copyWith(
        lifecycle: MediaUploadLifecycle.retryScheduled,
        retryCount: nextRetry,
        lastError: message,
        nextAttemptUtc: na,
        progress: 0,
        updatedAtUtc: now,
      );
    } else {
      list[i] = t.copyWith(
        lifecycle: MediaUploadLifecycle.failed,
        lastError: message,
        progress: 0,
        updatedAtUtc: now,
      );
      _analytics.recordTerminal(taskId: id, success: false, errorCode: message);
    }
    await _store.saveAll(list);
    await appendMediaUploadActivity(
      titleBn: retryable ? 'আপলোড পুনঃনির্ধারিত' : 'আপলোড ব্যর্থ',
      detailBn: message,
    );
  }

  Future<void> _driveTask(String id) async {
    for (var step = 0; step < 24; step++) {
      final list = await _store.loadAll();
      final i = list.indexWhere((e) => e.id == id);
      if (i < 0) return;
      final t = list[i];
      if (t.paused) return;
      if (t.lifecycle == MediaUploadLifecycle.completed ||
          t.lifecycle == MediaUploadLifecycle.failed) {
        return;
      }

      try {
        switch (t.lifecycle) {
          case MediaUploadLifecycle.retryScheduled:
            await _patch(
              id,
              (x) => x.copyWith(
                lifecycle: MediaUploadLifecycle.queued,
                clearNextAttempt: true,
                updatedAtUtc: DateTime.now().toUtc(),
              ),
            );
            continue;
          case MediaUploadLifecycle.queued:
            if (isRasterImageMime(t.mimeType) || isVideoMime(t.mimeType)) {
              await _patch(
                id,
                (x) => x.copyWith(
                  lifecycle: MediaUploadLifecycle.compressing,
                  progress: 0.05,
                  updatedAtUtc: DateTime.now().toUtc(),
                ),
              );
            } else {
              await _patch(
                id,
                (x) => x.copyWith(
                  lifecycle: MediaUploadLifecycle.preparing,
                  workingPath: x.sourcePath,
                  progress: 0.15,
                  updatedAtUtc: DateTime.now().toUtc(),
                ),
              );
            }
            continue;
          case MediaUploadLifecycle.compressing:
            final tmp = await getTemporaryDirectory();
            final dir = '${tmp.path}/pd_media_upload';
            await Directory(dir).create(recursive: true);
            if (isRasterImageMime(t.mimeType)) {
              final out = await _image.prepareRaster(
                sourcePath: t.sourcePath,
                tempDir: dir,
                taskId: id,
              );
              await _patch(
                id,
                (x) => x.copyWith(
                  workingPath: out.mainPath,
                  thumbnailPath: out.thumbnailPath,
                  lifecycle: MediaUploadLifecycle.preparing,
                  progress: 0.2,
                  updatedAtUtc: DateTime.now().toUtc(),
                ),
              );
            } else if (isVideoMime(t.mimeType)) {
              final dur = await _video.probeDuration(t.sourcePath);
              final thumb = await _video.generateThumbnail(
                videoPath: t.sourcePath,
                tempDir: dir,
              );
              await _patch(
                id,
                (x) => x.copyWith(
                  workingPath: x.sourcePath,
                  thumbnailPath: thumb,
                  durationMs: dur?.inMilliseconds,
                  lifecycle: MediaUploadLifecycle.preparing,
                  progress: 0.2,
                  updatedAtUtc: DateTime.now().toUtc(),
                ),
              );
            }
            continue;
          case MediaUploadLifecycle.preparing:
            if (!await _connectivity.isConnected) {
              await _fail(id, 'offline', retryable: true);
              return;
            }
            final path = t.workingPath ?? t.sourcePath;
            final f = File(path);
            if (!f.existsSync()) {
              await _fail(id, 'working_file_missing', retryable: false);
              return;
            }
            final preparedSize = f.lengthSync();
            final hash = await sha256HexForFile(path);
            final plan = ChunkUploadPlan.singlePart(preparedSize);
            await _patch(
              id,
              (x) => x.copyWith(
                sha256PreparedHex: hash,
                sizeBytesPrepared: preparedSize,
                chunkPlanJson: plan.toWireJson(),
                lifecycle: MediaUploadLifecycle.uploading,
                progress: 0.35,
                updatedAtUtc: DateTime.now().toUtc(),
              ),
            );
            continue;
          case MediaUploadLifecycle.uploading:
            if (!await _connectivity.isConnected) {
              await _fail(id, 'offline', retryable: true);
              return;
            }
            final path = t.workingPath ?? t.sourcePath;
            final fileName = path.split(RegExp(r'[\\/]')).last;
            final token = _tokenFor(id);
            final signed = await _signed.resolve(
              kind: t.kind,
              contentType: t.mimeType,
              sizeBytes: t.sizeBytesPrepared ?? File(path).lengthSync(),
              fileName: fileName,
            );
            if (signed != null) {
              await _api.dio.put<void>(
                signed.uploadUrl,
                data: File(path).openRead(),
                options: Options(
                  headers: <String, dynamic>{
                    ...signed.headers,
                    Headers.contentTypeHeader: t.mimeType,
                  },
                ),
                cancelToken: token,
              );
              await _patch(
                id,
                (x) => x.copyWith(
                  lifecycle: MediaUploadLifecycle.verifying,
                  progress: 0.88,
                  serverSizeBytes: x.sizeBytesPrepared,
                  updatedAtUtc: DateTime.now().toUtc(),
                ),
              );
            } else {
              final res = await _uploads.uploadMobileFile(
                purpose: t.purpose,
                filePath: path,
                fileName: fileName,
                cancelToken: token,
              );
              await _patch(
                id,
                (x) => x.copyWith(
                  lifecycle: MediaUploadLifecycle.verifying,
                  progress: 0.88,
                  serverFileId: res.fileId,
                  serverDownloadUrl: res.downloadUrl,
                  serverMimeType: res.mimeType,
                  serverSizeBytes: res.sizeBytes,
                  updatedAtUtc: DateTime.now().toUtc(),
                ),
              );
            }
            continue;
          case MediaUploadLifecycle.verifying:
            final list2 = await _store.loadAll();
            final j = list2.indexWhere((e) => e.id == id);
            if (j < 0) return;
            final v = list2[j];
            if (v.serverSizeBytes != null &&
                v.sizeBytesPrepared != null &&
                v.serverSizeBytes! > 0 &&
                (v.serverSizeBytes! - v.sizeBytesPrepared!).abs() > 64) {
              await _fail(id, 'integrity_size_mismatch', retryable: false);
              return;
            }
            await _patch(
              id,
              (x) => x.copyWith(
                lifecycle: MediaUploadLifecycle.completed,
                progress: 1,
                updatedAtUtc: DateTime.now().toUtc(),
              ),
            );
            _analytics.recordTerminal(taskId: id, success: true, errorCode: null);
            await appendMediaUploadActivity(
              titleBn: 'আপলোড সম্পন্ন',
              detailBn: v.displayName,
            );
            final done = (await _store.loadAll()).firstWhere((e) => e.id == id);
            await _store.deleteTempArtifacts(done);
            return;
          default:
            return;
        }
      } on DioException catch (e) {
        final retry = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            (e.response?.statusCode ?? 0) >= 500;
        await _fail(id, e.message ?? 'dio', retryable: retry);
        return;
      } catch (e) {
        await _fail(id, '$e', retryable: false);
        return;
      }
    }
  }
}
