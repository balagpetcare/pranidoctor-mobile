import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../partner_auth/data/partner_auth_repository.dart';

final partnerFreeZoneRepositoryProvider = Provider<PartnerFreeZoneRepository>((ref) {
  return PartnerFreeZoneRepository(ref.watch(dioProvider));
});

class FreeQuestion {
  const FreeQuestion({
    required this.id,
    required this.isEmergency,
    required this.symptoms,
    required this.animalName,
    required this.animalSpecies,
    required this.submittedAt,
  });
  final String id;
  final bool isEmergency;
  final String symptoms;
  final String animalName;
  final String animalSpecies;
  final DateTime? submittedAt;

  factory FreeQuestion.fromJson(Map<String, dynamic> j) {
    final a = j['animal'] is Map<String, dynamic> ? j['animal'] as Map<String, dynamic> : <String, dynamic>{};
    return FreeQuestion(
      id: '${j['id']}',
      isEmergency: j['isEmergency'] == true,
      symptoms: '${j['symptoms'] ?? ''}',
      animalName: '${a['name'] ?? ''}',
      animalSpecies: '${a['species'] ?? ''}',
      submittedAt: DateTime.tryParse('${j['submittedAt'] ?? ''}')?.toLocal(),
    );
  }
}

/// One question in the public Q&A feed (asker identity is never exposed).
class FreeFeedItem {
  const FreeFeedItem({
    required this.id,
    required this.symptoms,
    required this.species,
    required this.commentCount,
    required this.isEmergency,
    required this.submittedAt,
  });
  final String id;
  final String symptoms;
  final String species;
  final int commentCount;
  final bool isEmergency;
  final DateTime? submittedAt;

  factory FreeFeedItem.fromJson(Map<String, dynamic> j) => FreeFeedItem(
        id: '${j['id']}',
        symptoms: '${j['symptoms'] ?? ''}',
        species: '${j['species'] ?? ''}',
        commentCount: (j['commentCount'] as num?)?.toInt() ?? 0,
        isEmergency: j['isEmergency'] == true,
        submittedAt: DateTime.tryParse('${j['submittedAt'] ?? ''}')?.toLocal(),
      );
}

/// A comment on a free question. Doctors can comment and report; only the asker can hide.
class FreeThreadComment {
  const FreeThreadComment({
    required this.id,
    required this.body,
    required this.authorName,
    required this.verified,
    required this.isMine,
    required this.hidden,
    required this.canReport,
  });
  final String id;
  final String body;
  final String authorName;
  final bool verified;
  final bool isMine;
  final bool hidden;
  final bool canReport;

  factory FreeThreadComment.fromJson(Map<String, dynamic> j) => FreeThreadComment(
        id: '${j['id']}',
        body: '${j['body'] ?? ''}',
        authorName: '${j['authorName'] ?? 'গ্রাহক'}',
        verified: j['verified'] == true,
        isMine: j['isMine'] == true,
        hidden: j['hidden'] == true,
        canReport: j['canReport'] == true,
      );
}

class FreeSlot {
  const FreeSlot(this.id, this.startsAt, this.endsAt, this.capacity, this.mode, [this.bookedCount = 0]);
  final int bookedCount;
  final String id;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final String mode;

  factory FreeSlot.fromJson(Map<String, dynamic> j) => FreeSlot(
        '${j['id']}',
        DateTime.parse('${j['startsAt']}').toLocal(),
        DateTime.parse('${j['endsAt']}').toLocal(),
        (j['capacity'] as num?)?.toInt() ?? 1,
        '${j['mode'] ?? 'TEXT'}',
        (j['bookedCount'] as num?)?.toInt() ?? 0,
      );
}

class RewardPeriod {
  const RewardPeriod({
    required this.id,
    required this.title,
    required this.status,
    required this.endsAt,
    required this.prizes,
    this.resultRank,
    this.resultPrize,
    this.resultStatus,
    this.appealStatus,
  });
  final String id;
  final String title;
  final String status;
  final DateTime endsAt;
  final List<String> prizes;
  final int? resultRank;
  final String? resultPrize;
  final String? resultStatus;
  final String? appealStatus;

  bool get closed => status == 'CLOSED';

  factory RewardPeriod.fromJson(Map<String, dynamic> j) {
    final pr = j['prizes'];
    final res = j['myResult'] is Map<String, dynamic> ? j['myResult'] as Map<String, dynamic> : null;
    final ap = j['myAppeal'] is Map<String, dynamic> ? j['myAppeal'] as Map<String, dynamic> : null;
    return RewardPeriod(
      id: '${j['id']}',
      title: '${j['title']}',
      status: '${j['status']}',
      endsAt: DateTime.parse('${j['endsAt']}').toLocal(),
      prizes: pr is List
          ? pr.whereType<Map<String, dynamic>>().map((x) => '${x['rank']}ম: ${x['title']}').toList()
          : <String>[],
      resultRank: (res?['rank'] as num?)?.toInt(),
      resultPrize: res?['prizeTitle'] as String?,
      resultStatus: res?['status'] as String?,
      appealStatus: ap?['status'] as String?,
    );
  }
}

class LeaderRow {
  const LeaderRow(this.rank, this.name, this.points, this.verified, this.isMe);
  final int rank;
  final String name;
  final int points;
  final bool verified;
  final bool isMe;
}

class Leaderboard {
  const Leaderboard(this.rows, this.myRank, this.myPoints);
  final List<LeaderRow> rows;
  final int? myRank;
  final int myPoints;
}

class PartnerFreeZoneRepository {
  PartnerFreeZoneRepository(this._dio);
  final Dio _dio;
  static const _base = '/api/mobile/partner/free-zone';

  Future<List<FreeQuestion>> queue() async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_base/queue'));
    final raw = d['items'];
    return raw is List ? raw.whereType<Map<String, dynamic>>().map(FreeQuestion.fromJson).toList() : <FreeQuestion>[];
  }

  Future<void> claim(String id) async {
    await _call(() => _dio.post<Map<String, dynamic>>('$_base/queue/$id/claim'));
  }

  Future<int> points() async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_base/points'));
    return (d['total'] as num?)?.toInt() ?? 0;
  }

  Future<List<RewardPeriod>> rewards() async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_base/rewards'));
    final raw = d['items'];
    return raw is List ? raw.whereType<Map<String, dynamic>>().map(RewardPeriod.fromJson).toList() : <RewardPeriod>[];
  }

  Future<void> appeal(String periodId, String note) async {
    await _call(() => _dio.post<Map<String, dynamic>>('$_base/rewards/$periodId/appeal', data: {'note': note}));
  }

  Future<Leaderboard> leaderboard(String period) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_base/leaderboard', queryParameters: {'period': period}));
    final raw = d['top'];
    final rows = raw is List
        ? raw.whereType<Map<String, dynamic>>().map((j) => LeaderRow(
              (j['rank'] as num?)?.toInt() ?? 0,
              '${j['name'] ?? ''}',
              (j['points'] as num?)?.toInt() ?? 0,
              j['verified'] == true,
              j['isMe'] == true,
            )).toList()
        : <LeaderRow>[];
    final me = d['me'] is Map<String, dynamic> ? d['me'] as Map<String, dynamic> : null;
    return Leaderboard(rows, (me?['rank'] as num?)?.toInt(), (me?['points'] as num?)?.toInt() ?? 0);
  }

  Future<List<FreeSlot>> slots() async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_base/slots'));
    final raw = d['items'];
    return raw is List ? raw.whereType<Map<String, dynamic>>().map(FreeSlot.fromJson).toList() : <FreeSlot>[];
  }

  Future<void> addSlot({
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    required String mode,
  }) async {
    await _call(() => _dio.post<Map<String, dynamic>>('$_base/slots', data: {
          'startsAt': startsAt.toUtc().toIso8601String(),
          'endsAt': endsAt.toUtc().toIso8601String(),
          'capacity': capacity,
          'mode': mode,
        }));
  }

  Future<void> deleteSlot(String id) async {
    await _call(() => _dio.delete<Map<String, dynamic>>('$_base/slots/$id'));
  }

  Future<List<FreeFeedItem>> feed() async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_base/feed'));
    final raw = d['items'];
    return raw is List ? raw.whereType<Map<String, dynamic>>().map(FreeFeedItem.fromJson).toList() : <FreeFeedItem>[];
  }

  Future<List<FreeThreadComment>> comments(String questionId) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_base/questions/$questionId/comments'));
    final raw = d['items'];
    return raw is List ? raw.whereType<Map<String, dynamic>>().map(FreeThreadComment.fromJson).toList() : <FreeThreadComment>[];
  }

  /// Verified doctors only. Throws PartnerAuthException with the server's Bangla text on refusal.
  Future<void> postComment(String questionId, String body) async {
    await _call(() => _dio.post<Map<String, dynamic>>('$_base/questions/$questionId/comments', data: {'body': body.trim()}));
  }

  Future<void> reportComment(String commentId, {String? reason}) async {
    await _call(() => _dio.post<Map<String, dynamic>>('$_base/comments/$commentId/report', data: {
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        }));
  }

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() run) async {
    try {
      final res = await run();
      final body = res.data;
      if (body == null || body['ok'] != true) {
        throw PartnerAuthException(_msg(body) ?? 'অনুরোধ সম্পন্ন করা যায়নি।');
      }
      final d = body['data'];
      return d is Map<String, dynamic> ? d : <String, dynamic>{};
    } on DioException catch (e) {
      throw PartnerAuthException(
        _msg(e.response?.data) ??
            (e.response?.statusCode == 404
                ? 'সার্ভারে এই সুবিধা এখনো চালু হয়নি (৪০৪)।'
                : 'সার্ভারের সাথে সংযোগ হচ্ছে না। আবার চেষ্টা করুন।'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  String? _msg(Object? body) {
    if (body is Map<String, dynamic>) {
      final e = body['error'];
      if (e is Map<String, dynamic> && e['message'] is String) return e['message'] as String;
      if (body['message'] is String) return body['message'] as String;
    }
    return null;
  }
}
