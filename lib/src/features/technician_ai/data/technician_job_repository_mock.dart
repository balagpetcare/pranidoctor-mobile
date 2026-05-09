import 'package:pranidoctor_mobile/src/features/billing/data/billing_payment_summary_model.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_models.dart';
import 'package:pranidoctor_mobile/src/features/technician_ai/data/technician_job_repository.dart';

/// In-memory technician API for UI development. Remove `USE_MOCK_TECHNICIAN_API` for live HTTP.
///
/// Singleton so list/detail mutations persist across provider reads.
class TechnicianJobRepositoryMock implements TechnicianJobRepository {
  factory TechnicianJobRepositoryMock() => _i;
  TechnicianJobRepositoryMock._();
  static final TechnicianJobRepositoryMock _i = TechnicianJobRepositoryMock._();

  final Map<String, TechnicianJobDetail> _jobs = {
    'job-mock-1': TechnicianJobDetail(
      id: 'job-mock-1',
      serviceRequestId: 'sr-mock-1',
      status: 'ASSIGNED',
      phase: TechnicianWorkflowPhase.newRequest,
      animal: const TechnicianAnimalSummary(
        name: 'লালু',
        species: 'গরু',
        breed: 'সাহিওয়াল',
        animalType: 'CATTLE',
      ),
      customer: const TechnicianCustomerSummary(
        displayName: 'রহিম উদ্দিন',
        phoneHint: '01711******',
      ),
      locationText: 'আশুলিয়া, ঢাকা',
      problemOrSymptom: 'কৃত্রিম প্রজনন সেবা প্রয়োজন',
      description: 'দ্বিতীয় তৃণভোজের পর AI',
      preferredTime: 'সকাল ৯টার আগে',
      submittedAt: DateTime(2026, 5, 8, 10, 30),
      assignedAt: DateTime(2026, 5, 8, 14, 0),
    ),
    'job-mock-2': TechnicianJobDetail(
      id: 'job-mock-2',
      serviceRequestId: 'sr-mock-2',
      status: 'IN_PROGRESS',
      phase: TechnicianWorkflowPhase.active,
      animal: const TechnicianAnimalSummary(
        name: 'মনি',
        species: 'ছাগল',
        breed: 'ব্ল্যাক বেঙ্গল',
      ),
      customer: const TechnicianCustomerSummary(displayName: 'ফাতেমা বেগম'),
      locationText: 'গাজীপুর',
      problemOrSymptom: 'AI পরিদর্শন',
      submittedAt: DateTime(2026, 5, 7, 9, 0),
      startedAt: DateTime(2026, 5, 7, 11, 0),
    ),
    'job-mock-3': TechnicianJobDetail(
      id: 'job-mock-3',
      serviceRequestId: 'sr-mock-3',
      status: 'IN_PROGRESS',
      phase: TechnicianWorkflowPhase.serviceRecorded,
      animal: const TechnicianAnimalSummary(
        name: 'বুড়ি',
        species: 'গরু',
        breed: 'হলস্টিন ফ্রিজিয়ান',
      ),
      customer: const TechnicianCustomerSummary(displayName: 'করিম সাহেব'),
      locationText: 'টাঙ্গাইল',
      problemOrSymptom: 'AI সম্পন্ন রেকর্ড সংরক্ষণ',
      submittedAt: DateTime(2026, 5, 6, 8, 0),
      startedAt: DateTime(2026, 5, 6, 10, 0),
      hasAiRecord: true,
      aiRecord: TechnicianAiServiceRecord(
        animalType: 'গরু',
        breed: 'হলস্টিন ফ্রিজিয়ান',
        semenOrBreedTypeNote: 'স্ট্র #৪২১ (ডেমো)',
        servicePerformedAt: DateTime(2026, 5, 6, 11, 15),
        technicianNote: 'প্রক্রিয়া সুচারু।',
        followUpReminderNote: '২১ দিন পর পুনঃপরীক্ষা',
        billingNote: 'বিলিং — পরে নিশ্চিত করা হবে',
      ),
      billing: BillingPaymentSummary.demoForTechnicianJob(),
    ),
  };

  bool _isIncoming(TechnicianJobDetail j) {
    final s = j.status.toUpperCase();
    return s == 'PENDING' || s == 'ASSIGNED';
  }

  bool _isActiveJob(TechnicianJobDetail j) {
    final s = j.status.toUpperCase();
    if (s == 'COMPLETED' ||
        s == 'REJECTED' ||
        s == 'CANCELLED' ||
        s == 'CANCELED') {
      return false;
    }
    return !_isIncoming(j);
  }

  @override
  Future<({List<TechnicianIncomingRequest> requests, int total})> listRequests({
    int limit = 50,
    int offset = 0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final list = _jobs.values.where(_isIncoming).map(_toIncoming).toList();
    return (requests: list, total: list.length);
  }

  @override
  Future<({List<TechnicianJobSummary> jobs, int total})> listJobs({
    int limit = 50,
    int offset = 0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final list = _jobs.values.where(_isActiveJob).map(_toSummary).toList();
    return (jobs: list, total: list.length);
  }

  @override
  Future<TechnicianJobDetail> getJob(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final j = _jobs[id];
    if (j == null) {
      throw TechnicianApiException('খুঁজে পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    return j;
  }

  @override
  Future<TechnicianJobDetail> acceptJob(String id) async {
    final j = _jobs[id];
    if (j == null) {
      throw TechnicianApiException('খুঁজে পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    if (!j.canAccept) {
      throw TechnicianApiException(
        'এই অবস্থায় গ্রহণ করা যাবে না',
        code: 'INVALID_STATE',
      );
    }
    final u = j.copyWith(status: 'ACCEPTED', startedAt: DateTime.now());
    _jobs[id] = u;
    return u;
  }

  @override
  Future<TechnicianJobDetail> rejectJob(String id, {String? reason}) async {
    final j = _jobs[id];
    if (j == null) {
      throw TechnicianApiException('খুঁজে পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    final u = j.copyWith(status: 'REJECTED');
    _jobs[id] = u;
    return u;
  }

  @override
  Future<TechnicianJobDetail> saveAiRecord(
    String id,
    TechnicianAiRecordInput input,
  ) async {
    final j = _jobs[id];
    if (j == null) {
      throw TechnicianApiException('খুঁজে পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    final rec = TechnicianAiServiceRecord(
      animalType: input.animalType,
      breed: input.breed,
      semenOrBreedTypeNote: input.semenOrBreedTypeNote,
      servicePerformedAt: input.servicePerformedAt,
      technicianNote: input.technicianNote,
      followUpReminderNote: input.followUpReminderNote,
      billingNote: input.billingNote,
    );
    var next = j.copyWith(
      hasAiRecord: true,
      aiRecord: rec,
      status: j.status.toUpperCase() == 'ACCEPTED' ? 'IN_PROGRESS' : j.status,
    );
    if (next.status.toUpperCase() == 'ASSIGNED') {
      next = next.copyWith(status: 'IN_PROGRESS', startedAt: DateTime.now());
    }
    _jobs[id] = next;
    return next;
  }

  @override
  Future<TechnicianJobDetail> completeJob(String id) async {
    final j = _jobs[id];
    if (j == null) {
      throw TechnicianApiException('খুঁজে পাওয়া যায়নি', code: 'NOT_FOUND');
    }
    if (!j.canComplete) {
      throw TechnicianApiException(
        'আগে AI সেবার রেকর্ড সংরক্ষণ করুন',
        code: 'INVALID_STATE',
      );
    }
    final u = j.copyWith(status: 'COMPLETED', completedAt: DateTime.now());
    _jobs[id] = u;
    return u;
  }

  TechnicianIncomingRequest _toIncoming(TechnicianJobDetail j) {
    return TechnicianIncomingRequest(
      id: j.id,
      status: j.status,
      phase: j.phase,
      animal: j.animal,
      customer: j.customer,
      locationText: j.locationText,
      problemOrSymptom: j.problemOrSymptom,
      submittedAt: j.submittedAt,
    );
  }

  TechnicianJobSummary _toSummary(TechnicianJobDetail j) {
    return TechnicianJobSummary(
      id: j.id,
      status: j.status,
      phase: j.phase,
      animal: j.animal,
      customer: j.customer,
      locationText: j.locationText,
      submittedAt: j.submittedAt,
      hasAiRecord: j.hasAiRecord,
    );
  }
}
