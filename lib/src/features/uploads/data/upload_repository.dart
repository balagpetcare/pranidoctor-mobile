import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/core/network/mobile_api_envelope.dart';
import 'package:pranidoctor_mobile/src/features/uploads/data/uploaded_file_model.dart';

class UploadApiException implements Exception {
  UploadApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'UploadApiException($code): $message';
}

class UploadRepository {
  UploadRepository(this._client);

  final ApiClient _client;

  static const _uploads = '/api/mobile/uploads';

  Future<UploadedFileResult> uploadMobileFile({
    required String purpose,
    required String filePath,
    required String fileName,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final form = FormData.fromMap(<String, dynamic>{
        'purpose': purpose,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final res = await _client.dio.post<dynamic>(
        _uploads,
        data: form,
        options: Options(
          headers: <String, dynamic>{Headers.acceptHeader: 'application/json'},
        ),
        onSendProgress: onSendProgress,
      );

      final inner = unwrapOkDataMap(res.data);
      final fileId = inner['fileId'] as String?;
      final storageKey = inner['storageKey'] as String?;
      final downloadUrl = inner['downloadUrl'] as String?;
      final originalName = inner['originalName'] as String? ?? fileName;
      final mimeType =
          inner['mimeType'] as String? ?? 'application/octet-stream';
      final sizeRaw = inner['sizeBytes'];
      final sizeBytes = sizeRaw is num ? sizeRaw.toInt() : 0;
      if (fileId == null || storageKey == null || downloadUrl == null) {
        throw UploadApiException('অপ্রত্যাশিত আপলোড উত্তর');
      }
      return UploadedFileResult(
        fileId: fileId,
        storageKey: storageKey,
        downloadUrl: downloadUrl,
        originalName: originalName,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
      );
    } on UploadApiException {
      rethrow;
    } on MobileApiEnvelopeException catch (e) {
      throw UploadApiException(e.message, code: e.code);
    } on DioException catch (e, st) {
      assert(() {
        debugPrint('UploadRepository.uploadMobileFile: $e\n$st');
        return true;
      }());
      throw _mapDio(e);
    }
  }

  UploadApiException _mapDio(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['ok'] == false && data['error'] is Map) {
        final err = data['error'] as Map;
        final rawMsg = err['message'] is String
            ? err['message'] as String
            : 'আপলোড ব্যর্থ';
        final code = err['code'] is String ? err['code'] as String : null;
        return UploadApiException(_messageBn(code, rawMsg), code: code);
      }
    }
    final code = e.response?.statusCode;
    if (code == 413) {
      return UploadApiException(
        'ফাইলের আকার অনুমোদিত সীমার চেয়ে বড়।',
        code: 'FILE_TOO_LARGE',
      );
    }
    if (code == 415) {
      return UploadApiException(
        'এই ধরনের ফাইল গ্রহণ করা হয় না।',
        code: 'INVALID_TYPE',
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return UploadApiException(
        'সংযোগ সময় শেষ। আবার চেষ্টা করুন।',
        code: 'TIMEOUT',
      );
    }
    return UploadApiException('আপলোড করা যায়নি।', code: 'NETWORK');
  }

  static String _messageBn(String? code, String raw) {
    switch (code) {
      case 'FILE_TOO_LARGE':
        return 'ফাইলের আকার অনুমোদিত সীমার চেয়ে বড়। ছোট ফাইল বেছে নিন।';
      case 'INVALID_TYPE':
        return 'ফাইলের ধরন সমর্থিত নয় (JPEG, PNG, WebP বা PDF)।';
      case 'DANGEROUS_FILE':
        return 'এই ধরনের ফাইল গ্রহণ করা হয় না।';
      case 'STORAGE_NOT_CONFIGURED':
      case 'STORAGE_DISABLED':
        return 'সার্ভারে ফাইল সংরক্ষণ এখন সক্রিয় নয়। পরে চেষ্টা করুন।';
      case 'VALIDATION_ERROR':
        return 'অনুরোধ সঠিক নয়। আবার চেষ্টা করুন।';
      default:
        break;
    }
    return raw.trim().isNotEmpty ? raw : 'আপলোড করা যায়নি।';
  }
}
