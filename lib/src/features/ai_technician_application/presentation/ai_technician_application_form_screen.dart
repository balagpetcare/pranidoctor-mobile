import 'dart:async' show Timer, unawaited;
import 'dart:io' show File;
import 'dart:math' show max, min;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_info_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_app_header.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_fields.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_searchable_select_field.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_step_progress_header.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_upload_card.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_status_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_document_picker.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_service_area_selection_screen.dart';
import 'package:pranidoctor_mobile/src/features/locations/application/location_providers.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_models.dart';
import 'package:pranidoctor_mobile/src/core/network/api_client.dart';
import 'package:pranidoctor_mobile/src/features/uploads/application/upload_providers.dart';
import 'package:pranidoctor_mobile/src/features/uploads/data/upload_repository.dart';
import 'package:pranidoctor_mobile/src/features/uploads/data/uploaded_file_model.dart';

enum _ContactAvailability { idle, checking, available, duplicate, error }

/// Five-step wizard — `POST /apply` saves draft; `POST /submit` finalizes.
class AiTechnicianApplicationFormScreen extends ConsumerStatefulWidget {
  const AiTechnicianApplicationFormScreen({super.key, this.initialStep});

  /// Optional starting step (0-based). Pass `extra: 0` when pushing from the intro screen.
  final int? initialStep;

  static const routePath = '/profile/ai-technician/form';
  static const routeName = 'aiTechnicianForm';

  static const int totalSteps = 5;

  /// [SharedPreferences] keys for resuming the wizard (profile entry reads the same keys).
  static const String kWizardStepPrefsKey = 'ai_technician_wizard_step_v1';
  static const String kWizardStepPrefsKeyV2 = 'ai_technician_wizard_step_v2';
  static const String kWizardUserPrefsKey = 'ai_technician_wizard_user_v1';

  /// Maps legacy wizard indices (documents-before-address order) to V2 step order.
  static int migrateLegacyWizardStepIndexToV2(int legacyIndex) {
    switch (legacyIndex) {
      case 0:
        return 0;
      case 1:
        return 3;
      case 2:
        return 2;
      case 3:
        return 1;
      case 4:
        return 4;
      default:
        return legacyIndex.clamp(0, totalSteps - 1);
    }
  }

  /// Resume step for [userId], or null if none; prefers V2 prefs and migrates V1 once.
  static int? readWizardStepForResume(SharedPreferences prefs, String userId) {
    if (prefs.getString(kWizardUserPrefsKey) != userId) return null;
    final v2 = prefs.getInt(kWizardStepPrefsKeyV2);
    if (v2 != null) {
      return v2.clamp(0, totalSteps - 1);
    }
    final legacy = prefs.getInt(kWizardStepPrefsKey);
    if (legacy == null) return null;
    return migrateLegacyWizardStepIndexToV2(legacy).clamp(0, totalSteps - 1);
  }

  /// Progress header + AppBar copy (1-based display). Order: personal → area → experience → docs → review.
  static const List<String> stepTitlesBn = <String>[
    'ব্যক্তিগত তথ্য',
    'সেবা এলাকা নির্বাচন',
    'অভিজ্ঞতা ও দক্ষতা',
    'ডকুমেন্ট',
    'রিভিউ ও জমা',
  ];

  @override
  ConsumerState<AiTechnicianApplicationFormScreen> createState() =>
      _AiTechnicianApplicationFormScreenState();
}

class _AiTechnicianApplicationFormScreenState
    extends ConsumerState<AiTechnicianApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  int _stepIndex = 0;

  final FocusNode _focusDisplayName = FocusNode();
  final FocusNode _focusPhone = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final GlobalKey _addressSectionKey = GlobalKey();

  static const EdgeInsets _wizardFormCardPadding = EdgeInsets.all(16);

  /// Wizard gutters: tighter on small phones; 18–20px on larger phones; tablet uses [maxW] centering only.
  static double _wizardHorizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 390) return 16;
    if (w <= 600) {
      return 18 + (w - 390) / (600 - 390) * 2;
    }
    return 20;
  }

  /// Readable column: full width on phones; cap ~520 only when [width > 600].
  static double _wizardContentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w <= 600) return double.infinity;
    return w.clamp(0.0, 520.0);
  }

  double _effectiveContentMaxWidth(BuildContext context) {
    final m = _wizardContentMaxWidth(context);
    if (m.isFinite) return m;
    return MediaQuery.sizeOf(context).width;
  }

  void _showWizardSnackBar(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(behavior: SnackBarBehavior.fixed, content: Text(message)),
    );
  }

  late final TextEditingController _displayName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _nid;
  late final TextEditingController _dob;
  late final TextEditingController _presentAddress;
  late final TextEditingController _experienceYears;
  late final TextEditingController _training;
  late final TextEditingController _certNo;
  late final TextEditingController _certification;
  late final TextEditingController _bio;
  late final TextEditingController _fee;
  late final TextEditingController _visitFee;
  late final TextEditingController _emergencyFee;
  late final TextEditingController _followUpPolicy;
  late final TextEditingController _skillCategory;
  String? _experienceLevelBn;
  String? _gender;
  bool _acceptsEmergency = false;
  MobileLocationDto? _selectedDistrict;
  MobileLocationDto? _selectedUpazila;
  MobileLocationDto? _selectedUnion;
  AiTechnicianProfile? _profile;
  bool _loading = true;
  String? _loadError;
  bool _submitting = false;
  String? _fieldError;
  String? _stepError;
  bool _dirty = false;
  String? _inlineUploadingType;

  /// 0–1 while multipart upload reports progress; null = indeterminate bar.
  double? _uploadProgressFraction;

  /// Matches server `purposeMaxBytes` (`upload-service.ts`).
  static const _maxProfilePhotoBytes = 3 * 1024 * 1024;
  static const _maxCoverPhotoBytes = 5 * 1024 * 1024;
  static const _maxNidBytes = 8 * 1024 * 1024;
  static const _maxDocSlotBytes = 8 * 1024 * 1024;

  /// UX order for the documents step (subset of `AiTechnicianDocumentTypes`).
  static const _documentStepSlots = <String>[
    'PROFILE_PHOTO',
    'COVER_IMAGE',
    'NID_FRONT',
    'NID_BACK',
    'TRAINING_CERTIFICATE',
    'EXPERIENCE_PROOF',
  ];

  /// Serialized inside [AiTechnicianProfile.bio] without backend schema changes.
  static const String _kBioExtrasMarker = '--- অতিরিক্ত তথ্য ---';

  /// After first successful load, [_bootstrap] uses a lightweight refresh instead of toggling the whole form subtree.
  bool _initialBootstrapComplete = false;

  /// True while re-fetching profile without replacing the form body.
  bool _refreshing = false;

  /// While saving draft from **পরবর্তী** navigation.
  bool _navSaving = false;

  /// Apply [SharedPreferences] resume only once per screen instance.
  bool _resumeFromPrefsApplied = false;

  /// ISO [YYYY-MM-DD] from [showDatePicker]; optional. Kept in sync with [_dob] text.
  DateTime? _selectedDateOfBirth;

  /// Real-time contact availability (no dedicated duplicate-check API yet — see TODO below).
  /// TODO(backend): Add e.g. GET/POST .../check-contact?phone&email&excludeUserId and wire
  /// [_runPhoneAvailabilityEvaluation] / [_runEmailAvailabilityEvaluation] to set
  /// [duplicate] instead of [idle] for non-matching values.
  Timer? _phoneCheckDebounce;
  Timer? _emailCheckDebounce;

  _ContactAvailability _phoneContact = _ContactAvailability.idle;
  _ContactAvailability _emailContact = _ContactAvailability.idle;
  String? _phoneContactDetail;
  String? _emailContactDetail;

  static final _bdPhonePattern = RegExp(r'^01\d{9}$');

  /// Final step: user confirms accuracy before submit.
  bool _reviewDeclarationAccepted = false;

  /// Local path after pick/crop, until upload succeeds (or retry after failure).
  final Map<String, String> _docPendingPath = <String, String>{};

  /// Original display name for pending file.
  final Map<String, String> _docPendingName = <String, String>{};

  /// Bengali error message after failed upload (per slot).
  final Map<String, String> _docUploadErrorBn = <String, String>{};

  @override
  void initState() {
    super.initState();
    final raw = widget.initialStep;
    final start =
        (raw != null &&
            raw >= 0 &&
            raw < AiTechnicianApplicationFormScreen.totalSteps)
        ? raw
        : 0;
    _stepIndex = start;
    _displayName = TextEditingController();
    _phone = TextEditingController();
    _email = TextEditingController();
    _nid = TextEditingController();
    _dob = TextEditingController();
    _presentAddress = TextEditingController();
    _experienceYears = TextEditingController();
    _training = TextEditingController();
    _certNo = TextEditingController();
    _certification = TextEditingController();
    _bio = TextEditingController();
    _fee = TextEditingController();
    _visitFee = TextEditingController();
    _emergencyFee = TextEditingController();
    _followUpPolicy = TextEditingController();
    _skillCategory = TextEditingController();
    _attachDirtyListeners();
    _phone.addListener(_schedulePhoneAvailabilityCheck);
    _email.addListener(_scheduleEmailAvailabilityCheck);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _attachDirtyListeners() {
    void mark() {
      if (mounted) setState(() => _dirty = true);
    }

    for (final c in <TextEditingController>[
      _displayName,
      _phone,
      _email,
      _nid,
      _dob,
      _presentAddress,
      _experienceYears,
      _training,
      _certNo,
      _certification,
      _bio,
      _fee,
      _visitFee,
      _emergencyFee,
      _followUpPolicy,
      _skillCategory,
    ]) {
      c.addListener(mark);
    }
  }

  void _markClean() {
    setState(() => _dirty = false);
  }

  /// Wizard step index clamped to `[0, totalSteps - 1]` (prefs / bugs must not break titles or RangeError).
  int get _safeStepIndex {
    final maxIdx = AiTechnicianApplicationFormScreen.totalSteps - 1;
    return _stepIndex.clamp(0, maxIdx);
  }

  Future<void> _bootstrap({bool forceBlocking = false}) async {
    final blockUi = forceBlocking || !_initialBootstrapComplete;
    if (blockUi) {
      setState(() {
        _loading = true;
        _loadError = null;
        _refreshing = false;
      });
    } else {
      setState(() => _refreshing = true);
    }
    try {
      final repo = ref.read(aiTechnicianRepositoryProvider);
      var me = await repo.fetchMe();
      if (me.profile == null) {
        final created = await repo.apply(<String, dynamic>{});
        me = AiTechnicianMeResult(profile: created, serverMessage: null);
      }
      if (!mounted) return;
      final block = blockUi || !_dirty;
      if (block) {
        _fill(me.profile!);
      }
      setState(() {
        _profile = me.profile;
        _loading = false;
        _refreshing = false;
        _loadError = null;
        _initialBootstrapComplete = true;
      });
      if (kDebugMode) {
        debugPrint(
          'AiTechnicianApplicationForm bootstrap: profileStatus=${me.profile?.status} '
          'message=${me.serverMessage}',
        );
      }
      _markClean();
      ref.invalidate(aiTechnicianMeProvider);
      await _mergeResumeStepFromPrefsIfNeeded();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _runPhoneAvailabilityEvaluation();
        _runEmailAvailabilityEvaluation();
      });
    } catch (e, st) {
      assert(() {
        debugPrint('AiTechnician form bootstrap: $e\n$st');
        return true;
      }());
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
        if (blockUi) {
          _loadError = e is AiTechnicianApiException
              ? e.message
              : 'লোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করুন।';
        } else {
          _loadError = null;
          final msg = e is AiTechnicianApiException
              ? e.message
              : 'তথ্য আপডেট করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করুন।';
          _showWizardSnackBar(msg);
        }
      });
    }
  }

  Future<void> _persistWizardStep([int? step]) async {
    final p = _profile;
    if (p == null) return;
    final idx = step ?? _stepIndex;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AiTechnicianApplicationFormScreen.kWizardUserPrefsKey,
      p.userId,
    );
    await prefs.setInt(
      AiTechnicianApplicationFormScreen.kWizardStepPrefsKeyV2,
      idx,
    );
  }

  Future<void> _clearWizardStepPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AiTechnicianApplicationFormScreen.kWizardUserPrefsKey);
    await prefs.remove(AiTechnicianApplicationFormScreen.kWizardStepPrefsKey);
    await prefs.remove(AiTechnicianApplicationFormScreen.kWizardStepPrefsKeyV2);
  }

  Future<void> _mergeResumeStepFromPrefsIfNeeded() async {
    if (_resumeFromPrefsApplied || _profile == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = _profile!.userId;
      final savedUser = prefs.getString(
        AiTechnicianApplicationFormScreen.kWizardUserPrefsKey,
      );
      if (savedUser != uid) return;
      final saved = AiTechnicianApplicationFormScreen.readWizardStepForResume(
        prefs,
        uid,
      );
      if (saved == null) return;
      final routeStart = widget.initialStep ?? 0;
      final target = max(
        routeStart,
        saved,
      ).clamp(0, AiTechnicianApplicationFormScreen.totalSteps - 1);
      if (target == _stepIndex) return;
      if (!mounted) return;
      _commitStepIndex(target);
    } finally {
      _resumeFromPrefsApplied = true;
    }
  }

  void _commitStepIndex(int newIndex) {
    if (newIndex < 0 ||
        newIndex >= AiTechnicianApplicationFormScreen.totalSteps) {
      return;
    }
    if (kDebugMode) {
      debugPrint(
        'AiTechnicianWizard → step ${newIndex + 1}/'
        '${AiTechnicianApplicationFormScreen.totalSteps} · '
        '${AiTechnicianApplicationFormScreen.stepTitlesBn[newIndex]}',
      );
    }
    setState(() {
      _stepIndex = newIndex;
      if (newIndex != AiTechnicianApplicationFormScreen.totalSteps - 1) {
        _reviewDeclarationAccepted = false;
      }
    });
    unawaited(_persistWizardStep(newIndex));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _fill(AiTechnicianProfile p) {
    _displayName.text = p.displayName ?? '';
    _phone.text = p.phone ?? '';
    _email.text = p.email ?? '';
    _nid.text = p.nidNumber ?? '';
    _dob.text = p.dateOfBirth ?? '';
    _presentAddress.text = p.presentAddress ?? '';
    _hydrateLocationSelections(p);
    _experienceYears.text = p.experienceYears?.toString() ?? '';
    _training.text = p.trainingProvider ?? '';
    _certNo.text = p.certificateNumber ?? '';
    _certification.text = p.certification ?? '';
    _parseBioWithExtras(p.bio);
    _fee.text = p.serviceFeeBdt ?? '';
    _gender = p.gender;
    _acceptsEmergency = p.acceptsEmergency;
    _syncSelectedDateOfBirthFromDobText();
  }

  /// Parses [_dob] ISO text into [_selectedDateOfBirth] for date picker initial value.
  void _syncSelectedDateOfBirthFromDobText() {
    final t = _dob.text.trim();
    if (t.length >= 10) {
      final d = DateTime.tryParse(t.substring(0, 10));
      if (d != null) {
        _selectedDateOfBirth = DateTime(d.year, d.month, d.day);
        return;
      }
    }
    _selectedDateOfBirth = null;
  }

  DateTime _maximumSelectableBirthDate() {
    final now = DateTime.now();
    return DateTime(now.year - 18, now.month, now.day);
  }

  String _normalizedBdMobile(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('880') && d.length > 3) {
      d = d.substring(3);
    }
    if (d.length == 10 && d.startsWith('1')) {
      d = '0$d';
    }
    return d;
  }

  void _schedulePhoneAvailabilityCheck() {
    _phoneCheckDebounce?.cancel();
    _phoneCheckDebounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _runPhoneAvailabilityEvaluation();
    });
  }

  void _scheduleEmailAvailabilityCheck() {
    _emailCheckDebounce?.cancel();
    _emailCheckDebounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _runEmailAvailabilityEvaluation();
    });
  }

  void _runPhoneAvailabilityEvaluation() {
    if (!mounted) return;
    final n = _normalizedBdMobile(_phone.text);
    if (n.isEmpty) {
      setState(() {
        _phoneContact = _ContactAvailability.idle;
        _phoneContactDetail = null;
      });
      return;
    }
    setState(() {
      _phoneContact = _ContactAvailability.checking;
      _phoneContactDetail = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_bdPhonePattern.hasMatch(n)) {
        setState(() {
          _phoneContact = _ContactAvailability.error;
          _phoneContactDetail = '১১ সংখ্যার মোবাইল দিন (০১ দিয়ে শুরু)।';
        });
        return;
      }
      final profPhone = _profile?.phone?.trim();
      if (profPhone != null && _normalizedBdMobile(profPhone) == n) {
        setState(() {
          _phoneContact = _ContactAvailability.available;
          _phoneContactDetail = null;
        });
        return;
      }
      setState(() {
        _phoneContact = _ContactAvailability.idle;
        _phoneContactDetail = null;
      });
    });
  }

  void _runEmailAvailabilityEvaluation() {
    if (!mounted) return;
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailContact = _ContactAvailability.idle;
        _emailContactDetail = null;
      });
      return;
    }
    setState(() {
      _emailContact = _ContactAvailability.checking;
      _emailContactDetail = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
      if (!ok) {
        setState(() {
          _emailContact = _ContactAvailability.error;
          _emailContactDetail = 'ইমেইল ফর্ম্যাট ঠিক করুন।';
        });
        return;
      }
      final profEmail = _profile?.email?.trim().toLowerCase();
      if (profEmail != null && profEmail == email.toLowerCase()) {
        setState(() {
          _emailContact = _ContactAvailability.available;
          _emailContactDetail = null;
        });
        return;
      }
      setState(() {
        _emailContact = _ContactAvailability.idle;
        _emailContactDetail = null;
      });
    });
  }

  bool _availabilityBlocksPersonalNext() {
    if (_phoneContact == _ContactAvailability.checking ||
        _emailContact == _ContactAvailability.checking) {
      return true;
    }
    if (_phoneContact == _ContactAvailability.duplicate ||
        _emailContact == _ContactAvailability.duplicate) {
      return true;
    }
    if (_phoneContact == _ContactAvailability.error ||
        _emailContact == _ContactAvailability.error) {
      return true;
    }
    return false;
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final maxDob = _maximumSelectableBirthDate();
    final firstDate = DateTime(1950);
    final initial = _selectedDateOfBirth ?? maxDob;
    final clampedInitial = initial.isBefore(firstDate)
        ? firstDate
        : (initial.isAfter(maxDob) ? maxDob : initial);
    final picked = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: firstDate,
      lastDate: maxDob,
      helpText: 'জন্মতারিখ নির্বাচন করুন',
      cancelText: 'বাতিল',
      confirmText: 'ঠিক আছে',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _selectedDateOfBirth = DateTime(picked.year, picked.month, picked.day);
      _dob.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
      _dirty = true;
    });
  }

  Widget _contactAvailabilityLine({
    required _ContactAvailability status,
    required String checkingBn,
    required String duplicateBn,
    required String availableBn,
    required String errorFallbackBn,
    String? detail,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall;
    switch (status) {
      case _ContactAvailability.idle:
        return const SizedBox(height: PraniSpacing.xs);
      case _ContactAvailability.checking:
        return Padding(
          padding: const EdgeInsets.only(top: PraniSpacing.xs),
          child: Text(
            checkingBn,
            style: small?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        );
      case _ContactAvailability.available:
        return Padding(
          padding: const EdgeInsets.only(top: PraniSpacing.xs),
          child: Text(
            availableBn,
            style: small?.copyWith(color: scheme.primary, height: 1.35),
          ),
        );
      case _ContactAvailability.duplicate:
        return Padding(
          padding: const EdgeInsets.only(top: PraniSpacing.xs),
          child: Text(
            duplicateBn,
            style: small?.copyWith(color: scheme.error, height: 1.35),
          ),
        );
      case _ContactAvailability.error:
        return Padding(
          padding: const EdgeInsets.only(top: PraniSpacing.xs),
          child: Text(
            detail ?? errorFallbackBn,
            style: small?.copyWith(color: scheme.error, height: 1.35),
          ),
        );
    }
  }

  void _hydrateLocationSelections(AiTechnicianProfile p) {
    if (p.districtId != null &&
        p.districtId!.trim().isNotEmpty &&
        (p.district ?? '').trim().isNotEmpty) {
      _selectedDistrict = MobileLocationDto(
        id: p.districtId!.trim(),
        slug: '',
        nameBn: p.district!.trim(),
        nameEn: p.district!.trim(),
      );
    } else {
      _selectedDistrict = null;
    }
    if (p.upazilaId != null &&
        p.upazilaId!.trim().isNotEmpty &&
        (p.upazila ?? '').trim().isNotEmpty) {
      _selectedUpazila = MobileLocationDto(
        id: p.upazilaId!.trim(),
        slug: '',
        nameBn: p.upazila!.trim(),
        nameEn: p.upazila!.trim(),
      );
    } else {
      _selectedUpazila = null;
    }
    if (p.unionId != null &&
        p.unionId!.trim().isNotEmpty &&
        (p.unionOrArea ?? '').trim().isNotEmpty) {
      _selectedUnion = MobileLocationDto(
        id: p.unionId!.trim(),
        slug: '',
        nameBn: p.unionOrArea!.trim(),
        nameEn: p.unionOrArea!.trim(),
      );
    } else {
      _selectedUnion = null;
    }
    if (_selectedDistrict == null) {
      _selectedUpazila = null;
      _selectedUnion = null;
    }
    if (_selectedUpazila == null) {
      _selectedUnion = null;
    }
  }

  void _clearExtraBioControllers() {
    _visitFee.clear();
    _emergencyFee.clear();
    _followUpPolicy.clear();
    _skillCategory.clear();
    _experienceLevelBn = null;
  }

  /// Splits [raw] bio from server into main textarea + structured extras (সেভ করা খসড়া).
  void _parseBioWithExtras(String? raw) {
    final t = raw ?? '';
    final idx = t.indexOf(_kBioExtrasMarker);
    if (idx < 0) {
      _bio.text = t.trim();
      _clearExtraBioControllers();
      return;
    }
    _bio.text = t.substring(0, idx).trim();
    _clearExtraBioControllers();
    final rest = t.substring(idx + _kBioExtrasMarker.length).trim();
    for (final rawLine in rest.split('\n')) {
      final line = rawLine.trim();
      if (line.startsWith('ভিজিট ফি:')) {
        _visitFee.text = line
            .replaceFirst(RegExp(r'^ভিজিট ফি:\s*'), '')
            .replaceAll(RegExp(r'\s*টাকা\s*$'), '')
            .trim();
      } else if (line.startsWith('জরুরি সেবা ফি:')) {
        _emergencyFee.text = line
            .replaceFirst(RegExp(r'^জরুরি সেবা ফি:\s*'), '')
            .replaceAll(RegExp(r'\s*টাকা\s*$'), '')
            .trim();
      } else if (line.startsWith('ফলো-আপ নীতি:')) {
        _followUpPolicy.text = line
            .replaceFirst(RegExp(r'^ফলো-আপ নীতি:\s*'), '')
            .trim();
      } else if (line.startsWith('এআই/প্রজনন বিভাগ:')) {
        _skillCategory.text = line
            .replaceFirst(RegExp(r'^এআই/প্রজনন বিভাগ:\s*'), '')
            .trim();
      } else if (line.startsWith('অভিজ্ঞতার স্তর:')) {
        _experienceLevelBn = line
            .replaceFirst(RegExp(r'^অভিজ্ঞতার স্তর:\s*'), '')
            .trim();
      }
    }
  }

  String _composedBioForApply() {
    final core = _bio.text.trim();
    final extras = <String>[];
    if (_visitFee.text.trim().isNotEmpty) {
      extras.add('ভিজিট ফি: ${_visitFee.text.trim()} টাকা');
    }
    if (_emergencyFee.text.trim().isNotEmpty) {
      extras.add('জরুরি সেবা ফি: ${_emergencyFee.text.trim()} টাকা');
    }
    if (_followUpPolicy.text.trim().isNotEmpty) {
      extras.add('ফলো-আপ নীতি: ${_followUpPolicy.text.trim()}');
    }
    if (_skillCategory.text.trim().isNotEmpty) {
      extras.add('এআই/প্রজনন বিভাগ: ${_skillCategory.text.trim()}');
    }
    if (_experienceLevelBn != null && _experienceLevelBn!.trim().isNotEmpty) {
      extras.add('অভিজ্ঞতার স্তর: ${_experienceLevelBn!.trim()}');
    }
    if (extras.isEmpty) return core;
    final extraBlock = extras.join('\n');
    if (core.isEmpty) {
      return '$_kBioExtrasMarker\n$extraBlock';
    }
    return '$core\n\n$_kBioExtrasMarker\n$extraBlock';
  }

  Map<String, dynamic> _collectApplyBody() {
    int? years;
    final yText = _experienceYears.text.trim();
    if (yText.isNotEmpty) years = int.tryParse(yText);
    final m = <String, dynamic>{
      'displayName': _displayName.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
      'nidNumber': _nid.text.trim(),
      'dateOfBirth': _dob.text.trim().isEmpty ? null : _dob.text.trim(),
      'gender': _gender,
      'presentAddress': _presentAddress.text.trim(),
      'trainingProvider': _training.text.trim(),
      'certificateNumber': _certNo.text.trim(),
      'certification': _certification.text.trim(),
      'bio': _composedBioForApply(),
      'serviceFeeBdt': _fee.text.trim().isEmpty ? null : _fee.text.trim(),
      'acceptsEmergency': _acceptsEmergency,
    };
    if (years != null) {
      m['experienceYears'] = years;
    }
    final dSel = _selectedDistrict;
    final uSel = _selectedUpazila;
    final unionSel = _selectedUnion;
    if (dSel != null && uSel != null) {
      m['districtId'] = dSel.id;
      m['upazilaId'] = uSel.id;
      m['district'] = dSel.displayLabelBn;
      m['upazila'] = uSel.displayLabelBn;
      if (unionSel != null) {
        m['unionId'] = unionSel.id;
        m['unionOrArea'] = unionSel.displayLabelBn;
      } else {
        m['unionOrArea'] = null;
      }
    }
    return m;
  }

  Future<bool> _applyDraftForNavigation() async {
    if (_profile == null) return false;
    setState(() {
      _navSaving = true;
      _fieldError = null;
      _stepError = null;
    });
    try {
      final next = await ref
          .read(aiTechnicianRepositoryProvider)
          .apply(_collectApplyBody());
      if (!mounted) return false;
      setState(() {
        _profile = next;
        _navSaving = false;
      });
      _markClean();
      ref.invalidate(aiTechnicianMeProvider);
      unawaited(_persistWizardStep());
      return true;
    } catch (e) {
      if (!mounted) return false;
      final msg = e is AiTechnicianApiException
          ? e.message
          : 'সংরক্ষণ ব্যর্থ। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      setState(() {
        _navSaving = false;
        _fieldError = msg;
      });
      _showWizardSnackBar(msg);
      return false;
    }
  }

  bool _hasNid(AiTechnicianProfile p) {
    final t = p.documents.map((d) => d.type).toSet();
    return t.contains('NID_FRONT') && t.contains('NID_BACK');
  }

  List<AiTechnicianDivisionArea> _uniqueCoverageAreas(AiTechnicianProfile p) {
    final seen = <String>{};
    final unique = <AiTechnicianDivisionArea>[];
    for (final area in p.divisionCoverageAreas) {
      final key = [
        (area.districtId ?? area.district).trim().toLowerCase(),
        (area.upazilaId ?? area.upazila).trim().toLowerCase(),
        (area.unionId ?? area.unionOrArea ?? '').trim().toLowerCase(),
      ].join('|');
      if (seen.add(key)) {
        unique.add(area);
      }
    }
    return unique;
  }

  /// Phone typed in the form or already stored on the profile (server).
  bool _hasPhoneForSubmit([AiTechnicianProfile? profile]) {
    final local = _phone.text.trim();
    if (local.isNotEmpty) return true;
    final resolved = profile ?? _profile;
    final fromServer = resolved?.phone?.trim();
    return fromServer != null && fromServer.isNotEmpty;
  }

  String? _submitBlockedReason(AiTechnicianProfile profile) {
    if (_safeStepIndex != AiTechnicianApplicationFormScreen.totalSteps - 1) {
      return null;
    }
    final warnings = _reviewWarnings(profile);
    if (warnings.isNotEmpty) {
      return warnings.first;
    }
    if (!_reviewDeclarationAccepted) {
      return 'জমা দিতে নিশ্চিতকরণ বাক্সে টিক দিন।';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_safeStepIndex != AiTechnicianApplicationFormScreen.totalSteps - 1) {
      _showWizardSnackBar('জমা দিতে পর্যালোচনা ধাপে যান।');
      return;
    }
    final p0 = _profile;
    if (p0 != null && _reviewWarnings(p0).isNotEmpty) {
      setState(() {
        _fieldError = 'আগে সব আবশ্যক ধাপ পূর্ণ করুন।';
      });
      _showWizardSnackBar('আগে সব আবশ্যক ধাপ পূর্ণ করুন।');
      return;
    }
    if (!_reviewDeclarationAccepted) {
      _showWizardSnackBar(
        'জমা দিতে নিশ্চিতকরণ বাক্সে টিক দিন এবং তথ্য সঠিক আছে কি না যাচাই করুন।',
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _stepError = 'কিছু তথ্য সঠিক নয়। সংশ্লিষ্ট ধাপে ফিরে গিয়ে ঠিক করুন।';
      });
      return;
    }
    if (_selectedDistrict == null || _selectedUpazila == null) {
      setState(() {
        _fieldError = 'জেলা ও উপজেলা নির্বাচন করুন।';
      });
      _showWizardSnackBar(_fieldError!);
      return;
    }
    final p = _profile;
    if (p == null) return;
    if (!_hasNid(p)) {
      setState(() {
        _fieldError = 'জমা দিতে এনআইডি সামনে ও পিছনের নথি যোগ করুন।';
      });
      _showWizardSnackBar(_fieldError!);
      return;
    }
    final areas = _uniqueCoverageAreas(p);
    if (areas.isEmpty) {
      setState(() {
        _fieldError = 'কমপক্ষে একটি সেবা এলাকা যোগ করুন।';
      });
      _showWizardSnackBar(_fieldError!);
      return;
    }
    setState(() {
      _submitting = true;
      _fieldError = null;
      _stepError = null;
    });
    if (kDebugMode) {
      debugPrint('AiTechnicianForm submit start');
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: PraniSpacing.md),
              Expanded(
                child: Text(
                  'আবেদন জমা দেওয়া হচ্ছে…',
                  style: Theme.of(dialogCtx).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    try {
      final router = GoRouter.of(context);
      final repo = ref.read(aiTechnicianRepositoryProvider);
      await repo.apply(_collectApplyBody());
      if (!mounted) return;
      await repo.submit();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (kDebugMode) {
        debugPrint('AiTechnicianForm submit success');
      }
      ref.invalidate(aiTechnicianMeProvider);
      _markClean();
      _showWizardSnackBar('আবেদন জমা দেওয়া হয়েছে।');
      router.pushReplacement(AiTechnicianApplicationStatusScreen.routePath);
      unawaited(_clearWizardStepPrefs());
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _fieldError = e is AiTechnicianApiException ? e.message : 'জমা ব্যর্থ।';
      });
      if (kDebugMode) {
        debugPrint('AiTechnicianForm submit error: $e');
      }
      _showWizardSnackBar(_fieldError ?? 'জমা ব্যর্থ।');
    }
  }

  bool _validatePersonalStep() {
    setState(() => _stepError = null);
    if (_availabilityBlocksPersonalNext()) {
      setState(
        () => _stepError =
            'ফোন ও ইমেইল যাচাই সম্পূর্ণ করুন। ডুপ্লিকেট থাকলে অন্য নম্বর/ইমেইল দিন।',
      );
      return false;
    }
    if (_displayName.text.trim().length < 2) {
      setState(() => _stepError = 'প্রদর্শন নাম কমপক্ষে ২ অক্ষর দিন।');
      _focusFirstPersonalIssue();
      return false;
    }
    if (!_hasPhoneForSubmit()) {
      setState(() => _stepError = 'ফোন নম্বর দিন।');
      _focusFirstPersonalIssue();
      return false;
    }
    final email = _email.text.trim();
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _stepError = 'সঠিক ইমেইল দিন।');
      _focusFirstPersonalIssue();
      return false;
    }
    return true;
  }

  void _focusFirstPersonalIssue() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_displayName.text.trim().length < 2) {
        _focusDisplayName.requestFocus();
        return;
      }
      if (!_hasPhoneForSubmit()) {
        _focusPhone.requestFocus();
        return;
      }
      final email = _email.text.trim();
      if (email.isNotEmpty &&
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        _focusEmail.requestFocus();
      }
    });
  }

  bool _validateProfessionalStep() {
    setState(() => _stepError = null);
    final t = _experienceYears.text.trim();
    if (t.isEmpty) return true;
    final n = int.tryParse(t);
    if (n == null || n < 0 || n > 80) {
      setState(() => _stepError = 'অভিজ্ঞতা ০–৮০ বছরের মধ্যে দিন।');
      return false;
    }
    return true;
  }

  bool _validateAddressStep() {
    setState(() => _stepError = null);
    if (_selectedDistrict == null || _selectedUpazila == null) {
      setState(() => _stepError = 'জেলা ও উপজেলা নির্বাচন করুন।');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _addressSectionKey.currentContext;
        if (!mounted || ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.12,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      });
      return false;
    }
    final p = _profile;
    final uniqueAreas = p == null
        ? const <AiTechnicianDivisionArea>[]
        : _uniqueCoverageAreas(p);
    if (p != null && uniqueAreas.isEmpty) {
      setState(() => _stepError = 'কমপক্ষে একটি সেবা এলাকা যোগ করুন।');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _addressSectionKey.currentContext;
        if (!mounted || ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.12,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      });
      return false;
    }
    return true;
  }

  bool _validateDocumentsStep() {
    setState(() => _stepError = null);
    return true;
  }

  Future<void> _goNext() async {
    FocusScope.of(context).unfocus();
    if (_navSaving || _submitting) return;
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) {
      setState(
        () => _stepError =
            'ফর্মের তথ্য যাচাই করুন। লাল বার্তা অনুযায়ী ঠিক করুন।',
      );
      _showWizardSnackBar(_stepError!);
      return;
    }
    if (!_validateStep(_stepIndex)) return;
    if (_stepIndex >= AiTechnicianApplicationFormScreen.totalSteps - 1) {
      return;
    }
    if (_stepIndex >= 0 && _stepIndex <= 3) {
      final ok = await _applyDraftForNavigation();
      if (!ok) return;
    }
    final next = _stepIndex + 1;
    _commitStepIndex(next);
  }

  void _goPrevious() {
    FocusScope.of(context).unfocus();
    if (_stepIndex <= 0) return;
    _commitStepIndex(_stepIndex - 1);
  }

  void _goToStep(int index) {
    FocusScope.of(context).unfocus();
    if (index < 0 || index >= AiTechnicianApplicationFormScreen.totalSteps) {
      return;
    }
    _commitStepIndex(index);
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _validatePersonalStep();
      case 1:
        return _validateAddressStep();
      case 2:
        return _validateProfessionalStep();
      case 3:
        return _validateDocumentsStep();
      case 4:
        return true;
      default:
        return true;
    }
  }

  Future<void> _maybePopWizard() async {
    if (!_dirty) {
      if (mounted) context.pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('অসংরক্ষিত পরিবর্তন'),
        content: const Text(
          'আপনার কিছু পরিবর্তন খসড়ায় সংরক্ষিত নয়। ফিরে গেলে সেগুলো হারিয়ে যেতে পারে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('থাকুন'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ফিরে যান'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      context.pop();
    }
  }

  String _dobDisplayLabel() {
    final raw = _dob.text.trim();
    if (raw.isEmpty) return 'নির্বাচন করুন';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    try {
      return DateFormat.yMMMMd('bn_BD').format(d);
    } catch (_) {
      return DateFormat('d MMM y').format(d);
    }
  }

  AiTechnicianDocument? _docForType(AiTechnicianProfile p, String type) {
    for (final d in p.documents) {
      if (d.type == type) return d;
    }
    if (type == 'TRAINING_CERTIFICATE') {
      for (final d in p.documents) {
        if (d.type == 'AI_CERTIFICATE') return d;
      }
    }
    return null;
  }

  bool _pathLooksRaster(String path) {
    final l = path.toLowerCase();
    return l.endsWith('.jpg') ||
        l.endsWith('.jpeg') ||
        l.endsWith('.png') ||
        l.endsWith('.webp') ||
        l.endsWith('.heic');
  }

  Widget? _documentSlotPreview(String type, AiTechnicianDocument? existing) {
    final local = _docPendingPath[type];
    if (local != null) {
      if (_pathLooksRaster(local)) {
        return Image.file(
          File(local),
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
      if (local.toLowerCase().endsWith('.pdf')) {
        final scheme = Theme.of(context).colorScheme;
        final name = _docPendingName[type] ?? 'নথি.pdf';
        return ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(PraniSpacing.md),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_outlined, color: scheme.primary),
                const SizedBox(width: PraniSpacing.sm),
                Expanded(child: Text(name)),
              ],
            ),
          ),
        );
      }
    }
    return _documentPreviewWidget(existing);
  }

  Future<bool?> _confirmReplaceServerDocument(String slotLabelBn) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নথি পরিবর্তন'),
        content: Text(
          '$slotLabelBn — বিদ্যমান ফাইল সরিয়ে নতুন ফাইল আপলোড হবে। চালিয়ে যাবেন?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDeleteServerDocument(String slotLabelBn) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নথি মুছুন'),
        content: Text(
          'সার্ভার থেকে "$slotLabelBn" মুছে ফেলবেন? এই কাজটি পূরাবস্থায় ফেরানো যাবে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('থাকুন'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocumentSlot(String type) async {
    final p = _profile;
    if (p == null || !p.isEditable || _submitting) return;

    final retrying =
        _docUploadErrorBn.containsKey(type) && _docPendingPath[type] != null;
    late String path;
    late String displayName;

    if (retrying) {
      path = _docPendingPath[type]!;
      displayName = _docPendingName[type] ?? Uri.file(path).pathSegments.last;
    } else {
      final picked = await AiTechnicianDocumentPicker.pickForSlot(
        context,
        type: type,
      );
      if (!mounted) return;
      if (picked == null) return;

      final existing = _docForType(p, type);
      if (existing != null) {
        final ok = await _confirmReplaceServerDocument(
          AiTechnicianDocumentTypes.labelBn(type),
        );
        if (!mounted) return;
        if (ok != true) return;
      }

      path = picked.path;
      displayName = picked.name;
      setState(() {
        _docPendingPath[type] = path;
        _docPendingName[type] = displayName;
        _docUploadErrorBn.remove(type);
        _stepError = null;
      });
    }

    final len = await File(path).length();
    final maxBytes = _maxClientBytesForDocumentType(type);
    if (len > maxBytes) {
      if (mounted) {
        setState(() {
          _docUploadErrorBn[type] = 'ফাইল খুব বড়। ${_maxMbHintForType(type)}';
          _docPendingPath.remove(type);
          _docPendingName.remove(type);
          _inlineUploadingType = null;
          _uploadProgressFraction = null;
        });
      }
      return;
    }

    setState(() {
      _inlineUploadingType = type;
      _uploadProgressFraction = null;
      _stepError = null;
    });

    try {
      final purpose = mobileUploadPurposeForDocumentType(type);
      final upload = await ref
          .read(uploadRepositoryProvider)
          .uploadMobileFile(
            purpose: purpose,
            filePath: path,
            fileName: displayName,
            onSendProgress: (sent, total) {
              if (!mounted || total <= 0) return;
              setState(() => _uploadProgressFraction = sent / total);
            },
          );
      final baseTitle = AiTechnicianDocumentTypes.labelBn(type);
      var title = '$baseTitle · $displayName'.trim();
      if (title.length > 200) {
        title = '${title.substring(0, 197)}...';
      }
      final oldDoc = _docForType(_profile!, type);
      final oldId = oldDoc?.id;
      final newId = await ref
          .read(aiTechnicianRepositoryProvider)
          .addDocument(
            type: type,
            title: title,
            uploadedFileId: upload.fileId,
            mimeType: upload.mimeType,
          );
      if (oldId != null && oldId != newId) {
        try {
          await ref.read(aiTechnicianRepositoryProvider).deleteDocument(oldId);
        } catch (_) {
          /* duplicate row acceptable if delete fails */
        }
      }
      if (!mounted) return;
      await _bootstrap();
      if (!mounted) return;
      setState(() {
        _inlineUploadingType = null;
        _uploadProgressFraction = null;
        _docPendingPath.remove(type);
        _docPendingName.remove(type);
        _docUploadErrorBn.remove(type);
        _dirty = true;
      });
      _showWizardSnackBar('নথি সংযুক্ত হয়েছে।');
    } catch (e) {
      if (!mounted) return;
      final msg = e is UploadApiException
          ? e.message
          : e is AiTechnicianApiException
          ? e.message
          : 'আপলোড ব্যর্থ। আবার চেষ্টা করুন।';
      setState(() {
        _inlineUploadingType = null;
        _uploadProgressFraction = null;
        _docUploadErrorBn[type] = msg;
      });
      _showWizardSnackBar(msg);
    }
  }

  Future<void> _openServiceAreaSelection() async {
    final p = _profile;
    if (p == null || !p.isEditable) return;
    await context.push(
      AiTechnicianServiceAreaSelectionScreen.routePath,
      extra: List<AiTechnicianDivisionArea>.from(p.divisionCoverageAreas),
    );
    if (!mounted) return;
    await _bootstrap();
    ref.invalidate(aiTechnicianMeProvider);
    if (mounted) setState(() => _dirty = true);
  }

  Future<void> _delDoc(String type, String id) async {
    final ok = await _confirmDeleteServerDocument(
      AiTechnicianDocumentTypes.labelBn(type),
    );
    if (!mounted || ok != true) return;
    try {
      await ref.read(aiTechnicianRepositoryProvider).deleteDocument(id);
      if (!mounted) return;
      await _bootstrap();
      if (mounted) {
        setState(() {
          _docPendingPath.remove(type);
          _docPendingName.remove(type);
          _docUploadErrorBn.remove(type);
          _dirty = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showWizardSnackBar(
          e is AiTechnicianApiException ? e.message : 'মুছতে ব্যর্থ',
        );
      }
    }
  }

  Future<void> _delArea(String id) async {
    try {
      await ref
          .read(aiTechnicianRepositoryProvider)
          .deleteDivisionServiceArea(id);
      await _bootstrap();
      if (mounted) setState(() => _dirty = true);
    } catch (e) {
      if (mounted) {
        _showWizardSnackBar(
          e is AiTechnicianApiException ? e.message : 'মুছতে ব্যর্থ',
        );
      }
    }
  }

  Map<int, List<String>> _reviewIssuesByStep(AiTechnicianProfile p) {
    final m = <int, List<String>>{};
    void add(int step, String msg) {
      m.putIfAbsent(step, () => <String>[]).add(msg);
    }

    if (_displayName.text.trim().length < 2) {
      add(0, 'প্রদর্শন নাম পূর্ণ করুন।');
    }
    if (!_hasPhoneForSubmit(p)) {
      add(0, 'ফোন নম্বর দিন (অথবা প্রোফাইলে সংরক্ষিত নম্বর থাকতে হবে)।');
    }
    final dobRaw = _dob.text.trim();
    if (dobRaw.isNotEmpty) {
      final iso = dobRaw.length >= 10 ? dobRaw.substring(0, 10) : dobRaw;
      if (DateTime.tryParse(iso) == null) {
        add(0, 'জন্মতারিখের ফর্ম্যাট ঠিক করুন।');
      }
    }
    final email = _email.text.trim();
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      add(0, 'সঠিক ইমেইল দিন।');
    }

    final exp = _experienceYears.text.trim();
    if (exp.isNotEmpty) {
      final n = int.tryParse(exp);
      if (n == null || n < 0 || n > 80) {
        add(2, 'অভিজ্ঞতা ০–৮০ বছরের মধ্যে দিন।');
      }
    }

    if (_selectedDistrict == null || _selectedUpazila == null) {
      add(1, 'ঠিকানার জন্য জেলা ও উপজেলা নির্বাচন করুন।');
    }
    if (_uniqueCoverageAreas(p).isEmpty) {
      add(1, 'কমপক্ষে একটি সেবা এলাকা যোগ করুন।');
    }

    if (!_hasNid(p)) {
      add(3, 'এনআইডি সামনে ও পিছনের নথি আপলোড করুন।');
    }

    return m;
  }

  List<String> _reviewWarnings(AiTechnicianProfile p) {
    final flat = <String>[];
    for (final list in _reviewIssuesByStep(p).values) {
      flat.addAll(list);
    }
    return flat;
  }

  /// Keys match Step 6 summary cards (fees share edit step with professional).
  Map<String, List<String>> _reviewIssuesByGroup(AiTechnicianProfile p) {
    final byStep = _reviewIssuesByStep(p);
    return <String, List<String>>{
      'personal': List<String>.from(byStep[0] ?? const <String>[]),
      'professional': List<String>.from(byStep[2] ?? const <String>[]),
      'address': List<String>.from(byStep[1] ?? const <String>[]),
      'documents': List<String>.from(byStep[3] ?? const <String>[]),
      'fees': const <String>[],
    };
  }

  int _maxClientBytesForDocumentType(String type) {
    switch (type) {
      case 'PROFILE_PHOTO':
        return _maxProfilePhotoBytes;
      case 'COVER_IMAGE':
        return _maxCoverPhotoBytes;
      case 'NID_FRONT':
      case 'NID_BACK':
        return _maxNidBytes;
      case 'TRAINING_CERTIFICATE':
      case 'AI_CERTIFICATE':
      case 'OTHER':
      case 'COMPANY_ID':
      case 'EXPERIENCE_PROOF':
      default:
        return _maxDocSlotBytes;
    }
  }

  String _maxMbHintForType(String type) {
    final mb = (_maxClientBytesForDocumentType(type) / (1024 * 1024)).round();
    return 'এই স্লটের জন্য সর্বোচ্চ প্রায় $mb মেগাবাইট।';
  }

  /// Accepted formats + max size for each slot (Bengali).
  String _docFootnote(String type) {
    final imageOnly =
        type == 'PROFILE_PHOTO' ||
        type == 'COVER_IMAGE' ||
        type == 'NID_FRONT' ||
        type == 'NID_BACK';
    final typesBn = imageOnly ? 'JPG, PNG, WEBP' : 'JPG, PNG, WEBP, PDF';
    return '$typesBn · ${_maxMbHintForType(type)}';
  }

  InputDecorationThemeData _inputDecorationTheme(BuildContext context) {
    final base = Theme.of(context).inputDecorationTheme;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderOutline = scheme.outline.withValues(alpha: 0.65);
    return base.copyWith(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      constraints: const BoxConstraints(minHeight: 56),
      labelStyle: PraniTextStyles.formLabel(
        scheme,
        textTheme,
      ).copyWith(fontSize: 14.5, height: 1.42),
      helperStyle: PraniTextStyles.formHelper(
        scheme,
        textTheme,
      ).copyWith(fontSize: 13, height: 1.45),
      errorStyle: PraniTextStyles.caption(
        scheme,
        textTheme,
      ).copyWith(color: scheme.error, height: 1.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadius.md),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadius.md),
        borderSide: BorderSide(color: borderOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PraniRadius.md),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _phone.removeListener(_schedulePhoneAvailabilityCheck);
    _email.removeListener(_scheduleEmailAvailabilityCheck);
    _phoneCheckDebounce?.cancel();
    _emailCheckDebounce?.cancel();
    _scrollController.dispose();
    _displayName.dispose();
    _phone.dispose();
    _email.dispose();
    _nid.dispose();
    _dob.dispose();
    _presentAddress.dispose();
    _experienceYears.dispose();
    _training.dispose();
    _certNo.dispose();
    _certification.dispose();
    _bio.dispose();
    _fee.dispose();
    _visitFee.dispose();
    _emergencyFee.dispose();
    _followUpPolicy.dispose();
    _skillCategory.dispose();
    _focusDisplayName.dispose();
    _focusPhone.dispose();
    _focusEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = _wizardHorizontalPadding(context);
    final maxW = _wizardContentMaxWidth(context);
    final scheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: scheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('এআই টেকনিশিয়ান আবেদন'),
        ),
        body: const SafeArea(
          child: Center(
            child: PraniLoadingState(
              message: 'আপনার আবেদন তথ্য লোড হচ্ছে…',
              compact: false,
            ),
          ),
        ),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: scheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('এআই টেকনিশিয়ান আবেদন'),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(hPad),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: PraniErrorState(
                  title: 'লোড ব্যর্থ',
                  message: _loadError!,
                  retryLabel: 'আবার চেষ্টা',
                  onRetry: () => _bootstrap(forceBlocking: true),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: scheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('এআই টেকনিশিয়ান আবেদন'),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(hPad),
              child: PraniErrorState(
                title: 'প্রোফাইল লোড হয়নি',
                message: 'আবার চেষ্টা করুন।',
                retryLabel: 'আবার চেষ্টা',
                onRetry: () => _bootstrap(forceBlocking: true),
              ),
            ),
          ),
        ),
      );
    }

    final p = _profile!;
    final editable = p.isEditable;
    if (!editable) {
      return Scaffold(
        backgroundColor: scheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const PraniAppHeader(
            title: 'এআই টেকনিশিয়ান আবেদন',
            subtitle: 'শুধু দেখুন',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              hPad,
              PraniSpacing.sm,
              hPad,
              PraniSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxW.isFinite
                        ? maxW
                        : _effectiveContentMaxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PraniFormCard(
                        cardPadding: _wizardFormCardPadding,
                        child: ListTile(
                          leading: Icon(
                            Icons.lock_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: const Text('সম্পাদনা বন্ধ'),
                          subtitle: const Text(
                            'এই অবস্থায় ফর্ম পরিবর্তন করা যাবে না।',
                          ),
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.lg),
                      PraniPrimaryButton(
                        label: 'অবস্থা দেখুন',
                        onPressed: () => context.push(
                          AiTechnicianApplicationStatusScreen.routePath,
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      PraniSecondaryButton(
                        label: 'ফিরে যান',
                        fullWidth: true,
                        style: PraniSecondaryStyle.text,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final uiStep = _safeStepIndex;
    if (uiStep != _stepIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _stepIndex = uiStep);
      });
    }

    const total = AiTechnicianApplicationFormScreen.totalSteps;

    final stepNavBroken = uiStep < 0 || uiStep >= total;

    final contentMaxW = _effectiveContentMaxWidth(context);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _maybePopWizard();
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('এআই টেকনিশিয়ান আবেদন'),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_refreshing)
                LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: _inputDecorationTheme(context),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      PraniSpacing.md,
                      PraniSpacing.lg,
                      PraniSpacing.md,
                      PraniSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxW),
                          child: PraniStepProgressHeader(
                            stepIndexZeroBased: uiStep,
                            totalSteps: total,
                            stepTitleBn: AiTechnicianApplicationFormScreen
                                .stepTitlesBn[uiStep],
                            compact: true,
                            alertChildren: [
                              if (p.correctionNote != null &&
                                  p.correctionNote!.trim().isNotEmpty) ...[
                                PraniFormCard(
                                  cardPadding: _wizardFormCardPadding,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.feedback_outlined,
                                      color: scheme.primary,
                                    ),
                                    title: const Text('সংশোধন নোট (অ্যাডমিন)'),
                                    subtitle: Text(p.correctionNote!.trim()),
                                  ),
                                ),
                              ],
                              if (p.correctionNote != null &&
                                  p.correctionNote!.trim().isNotEmpty &&
                                  _fieldError != null)
                                const SizedBox(height: PraniSpacing.sm),
                              if (_fieldError != null)
                                PraniErrorState(
                                  title: 'মনোযোগ দিন',
                                  message: _fieldError!,
                                  compact: true,
                                  boxed: true,
                                ),
                              if (_fieldError != null && _stepError != null)
                                const SizedBox(height: PraniSpacing.sm),
                              if (_stepError != null)
                                PraniErrorState(
                                  title: 'এই ধাপে ঠিক করুন',
                                  message: _stepError!,
                                  compact: true,
                                  boxed: true,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: KeyedSubtree(
                            key: ValueKey<int>(uiStep),
                            child: _buildCurrentStepContentV2(p),
                          ),
                        ),
                        SizedBox(
                          height:
                              96 + MediaQuery.viewPaddingOf(context).bottom,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildInlineBottomActionsV2(p, stepNavBroken: stepNavBroken),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContentV2(AiTechnicianProfile profile) {
    final maxW = _wizardContentMaxWidth(context);
    final editable = profile.isEditable;
    switch (_safeStepIndex) {
      case 0:
        return _buildStepPersonalV2(context, maxW, editable, profile);
      case 1:
        return _buildStepServiceAreaV2(context, maxW, profile, editable);
      case 2:
        return _buildStepExperienceV2(context, maxW, editable);
      case 3:
        return _buildStepDocumentsV2(context, maxW, profile, editable);
      case 4:
        return _buildStepReviewV2(context, maxW, profile, editable);
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: PraniSpacing.lg),
          child: PraniErrorState(
            title: 'ধাপ দেখানো যাচ্ছে না',
            message: 'এই ধাপের তথ্য দেখানো যাচ্ছে না। আবার চেষ্টা করুন।',
            retryLabel: 'আবার চেষ্টা',
            onRetry: () => _bootstrap(forceBlocking: true),
            boxed: true,
          ),
        );
    }
  }

  Widget _buildStepPersonalV2(
    BuildContext context,
    double maxW,
    bool editable,
    AiTechnicianProfile profile,
  ) {
    return _buildStepPersonal(context, maxW, editable, profile);
  }

  Widget _buildStepServiceAreaV2(
    BuildContext context,
    double maxW,
    AiTechnicianProfile profile,
    bool editable,
  ) {
    return _buildStepAddress(context, maxW, profile, editable);
  }

  Widget _buildStepExperienceV2(
    BuildContext context,
    double maxW,
    bool editable,
  ) {
    return _buildStepProfessional(context, maxW, editable);
  }

  Widget _buildStepDocumentsV2(
    BuildContext context,
    double maxW,
    AiTechnicianProfile profile,
    bool editable,
  ) {
    return _buildStepDocuments(context, maxW, profile, editable);
  }

  Widget _buildStepReviewV2(
    BuildContext context,
    double maxW,
    AiTechnicianProfile profile,
    bool editable,
  ) {
    return _buildStepReview(context, maxW, profile, editable);
  }

  Widget _buildInlineBottomActionsV2(
    AiTechnicianProfile profile, {
    required bool stepNavBroken,
  }) {
    if (stepNavBroken) {
      return SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              PraniSpacing.md,
              PraniSpacing.sm,
              PraniSpacing.md,
              PraniSpacing.md,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stackVertical = constraints.maxWidth < 380;
                if (stackVertical) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PraniPrimaryButton(
                        label: 'আবার চেষ্টা',
                        fullWidth: true,
                        minimumHeight: 56,
                        onPressed: (_submitting || _navSaving)
                            ? null
                            : () => _bootstrap(forceBlocking: true),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      PraniSecondaryButton(
                        label: 'ফিরে যান',
                        fullWidth: true,
                        minimumHeight: 56,
                        style: PraniSecondaryStyle.text,
                        onPressed: (_submitting || _navSaving)
                            ? null
                            : () => context.pop(),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: PraniSecondaryButton(
                        label: 'ফিরে যান',
                        fullWidth: true,
                        minimumHeight: 56,
                        style: PraniSecondaryStyle.text,
                        onPressed: (_submitting || _navSaving)
                            ? null
                            : () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: PraniSpacing.md),
                    Expanded(
                      child: PraniPrimaryButton(
                        label: 'আবার চেষ্টা',
                        fullWidth: true,
                        minimumHeight: 56,
                        onPressed: (_submitting || _navSaving)
                            ? null
                            : () => _bootstrap(forceBlocking: true),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    final step = _safeStepIndex;
    final isFirst = step == 0;
    final isLast = step == AiTechnicianApplicationFormScreen.totalSteps - 1;
    final submitBlockedReason = _submitBlockedReason(profile);
    final submitBlockedOnReview = isLast && submitBlockedReason != null;
    final contactGate = isFirst && _availabilityBlocksPersonalNext();

    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PraniSpacing.md,
            PraniSpacing.sm,
            PraniSpacing.md,
            PraniSpacing.md,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackVertical = constraints.maxWidth < 380;

              final prev = PraniSecondaryButton(
                label: 'পূর্ববর্তী',
                fullWidth: true,
                minimumHeight: 56,
                onPressed: (_submitting || _navSaving) ? null : _goPrevious,
              );

              final next = isLast
                  ? PraniPrimaryButton(
                      label: 'আবেদন জমা দিন',
                      fullWidth: true,
                      isLoading: _submitting,
                      minimumHeight: 56,
                      onPressed:
                          (_navSaving || _submitting || submitBlockedOnReview)
                          ? null
                          : _submit,
                    )
                  : PraniPrimaryButton(
                      label: 'পরবর্তী',
                      fullWidth: true,
                      isLoading: _navSaving,
                      minimumHeight: 56,
                      onPressed: (_navSaving || _submitting || contactGate)
                          ? null
                          : () => _goNext(),
                    );

              if (isFirst) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [next],
                );
              }

              if (stackVertical) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    prev,
                    const SizedBox(height: PraniSpacing.sm),
                    next,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: prev),
                  const SizedBox(width: PraniSpacing.md),
                  Expanded(child: next),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _wizardStepColumn(
    BuildContext context,
    double maxW,
    List<Widget> children,
  ) {
    // Never use [Center]/[Align] as the root of scroll content: inside
    // [SingleChildScrollView] the main-axis max is unbounded and some devices
    // resolve this to zero height for the subtree (blank step body).
    final vw = MediaQuery.sizeOf(context).width;
    final contentW = maxW.isFinite
        ? min(vw, maxW)
        : (vw.isFinite ? vw : double.infinity);

    return SizedBox(
      width: contentW.isFinite && contentW > 0 ? contentW : vw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  /// Shared step title block for V2 wizard steps (below [PraniStepProgressHeader]).
  Widget _buildStepShellV2({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: PraniTextStyles.subheading(scheme, textTheme).copyWith(
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        if (subtitle != null && subtitle.trim().isNotEmpty) ...[
          const SizedBox(height: PraniSpacing.xs),
          Text(
            subtitle.trim(),
            style: PraniTextStyles.formHelper(scheme, textTheme).copyWith(
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: PraniSpacing.md),
        child,
      ],
    );
  }

  Widget _buildStepPersonal(
    BuildContext context,
    double maxW,
    bool editable,
    AiTechnicianProfile profile,
  ) {
    final phoneLocked = editable && (profile.phone?.trim().isNotEmpty ?? false);

    return _wizardStepColumn(context, maxW, [
      _buildStepShellV2(
        title: 'ব্যক্তিগত তথ্য',
        subtitle: 'নাম ও পরিচয়',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PraniInfoCard(
              title: 'কী প্রয়োজন',
              subtitle:
                  'প্রদর্শন নাম ও ফোন নম্বর আবশ্যক। ইমেইল, জন্মতারিখ ও লিঙ্গ ঐচ্ছিক। এনআইডি ছবি পরের ধাপে যোগ করা যাবে।',
              leadingIcon: const Icon(Icons.info_outline_rounded, size: 22),
            ),
            const SizedBox(height: PraniSpacing.sm),
            PraniFormCard(
              cardPadding: _wizardFormCardPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 200),
                child: Column(
                  children: [
              PraniTextField(
                controller: _displayName,
                focusNode: _focusDisplayName,
                enabled: editable,
                decoration: const InputDecoration(
                  labelText: 'প্রদর্শন নাম *',
                  hintText: 'যে নামটি খামারিতে দেখাবে',
                ),
                validator: (v) => (v ?? '').trim().length < 2
                    ? 'কমপক্ষে ২ অক্ষরের নাম দিন।'
                    : null,
              ),
              SizedBox(height: PraniFormTokens.fieldGap),
              PraniTextField(
                controller: _phone,
                focusNode: _focusPhone,
                readOnly: phoneLocked,
                enabled: editable,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'ফোন *',
                  helperText: 'যোগাযোগের জন্য প্রয়োজনীয়',
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'ফোন নম্বর দিন।' : null,
              ),
              _contactAvailabilityLine(
                status: _phoneContact,
                checkingBn: 'মোবাইল নম্বর যাচাই হচ্ছে…',
                duplicateBn: 'এই মোবাইল নম্বরটি আগে ব্যবহার করা হয়েছে',
                availableBn: 'মোবাইল নম্বর ব্যবহারযোগ্য',
                errorFallbackBn: 'মোবাইল নম্বর যাচাই করা যায়নি',
                detail: _phoneContactDetail,
              ),
              SizedBox(height: PraniFormTokens.fieldGap),
              PraniTextField(
                controller: _email,
                focusNode: _focusEmail,
                enabled: editable,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'ইমেইল (ঐচ্ছিক)'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                      ? null
                      : 'সঠিক ইমেইল দিন।';
                },
              ),
              _contactAvailabilityLine(
                status: _emailContact,
                checkingBn: 'ইমেইল যাচাই হচ্ছে…',
                duplicateBn: 'এই ইমেইলটি আগে ব্যবহার করা হয়েছে',
                availableBn: 'ইমেইল ব্যবহারযোগ্য',
                errorFallbackBn: 'ইমেইল যাচাই করা যায়নি',
                detail: _emailContactDetail,
              ),
              SizedBox(height: PraniFormTokens.fieldGap),
              PraniTextField(
                controller: _nid,
                enabled: editable,
                decoration: const InputDecoration(
                  labelText: 'এনআইডি নম্বর (ঐচ্ছিক)',
                  helperText: 'জমা দিতে এনআইডি ছবি আলাদা ধাপে প্রয়োজন',
                ),
              ),
              SizedBox(height: PraniFormTokens.fieldGap),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(PraniRadius.md),
                  onTap: editable ? () => _pickDateOfBirth(context) : null,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'জন্মতারিখ (ঐচ্ছিক)',
                      helperText: 'বয়স যাচাইয়ের জন্য জন্মতারিখ নির্বাচন করুন',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLow,
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dob.text.trim().isNotEmpty && editable)
                            IconButton(
                              tooltip: 'মুছুন',
                              onPressed: () {
                                setState(() {
                                  _dob.clear();
                                  _selectedDateOfBirth = null;
                                  _dirty = true;
                                });
                              },
                              icon: const Icon(Icons.clear, size: 20),
                            ),
                          const Icon(Icons.calendar_month_outlined, size: 22),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _dobDisplayLabel(),
                          style: PraniTextStyles.input(
                            Theme.of(context).colorScheme,
                            Theme.of(context).textTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: PraniFormTokens.fieldGap),
              PraniDropdownField<String?>(
                value: _gender,
                enabled: editable,
                decoration: const InputDecoration(labelText: 'লিঙ্গ'),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('নির্বাচন করুন'),
                  ),
                  DropdownMenuItem(value: 'MALE', child: Text('পুরুষ')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('নারী')),
                  DropdownMenuItem(value: 'OTHER', child: Text('অন্যান্য')),
                  DropdownMenuItem(
                    value: 'UNKNOWN',
                    child: Text('বলতে চাই না'),
                  ),
                ],
                onChanged: editable
                    ? (v) => setState(() {
                        _gender = v;
                        _dirty = true;
                      })
                    : null,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
    ]);
  }

  Widget _buildStepProfessional(
    BuildContext context,
    double maxW,
    bool editable,
  ) {
    return _wizardStepColumn(context, maxW, [
      _buildStepShellV2(
        title: 'অভিজ্ঞতা ও দক্ষতা',
        subtitle: 'অভিজ্ঞতা, সেবামূল্য ও সার্টিফিকেট',
        child: PraniFormCard(
          cardPadding: _wizardFormCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            PraniDropdownField<String?>(
              value: _experienceLevelBn,
              enabled: editable,
              decoration: const InputDecoration(
                labelText: 'অভিজ্ঞতার স্তর (ঐচ্ছিক)',
                helperText: 'ক্ষেত্রে কাজের ধরন বেছে নিন',
              ),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('নির্বাচন করুন'),
                ),
                DropdownMenuItem(
                  value: 'নবীন (০–২ বছর)',
                  child: Text('নবীন (০–২ বছর)'),
                ),
                DropdownMenuItem(
                  value: 'মাঝারি (৩–৭ বছর)',
                  child: Text('মাঝারি (৩–৭ বছর)'),
                ),
                DropdownMenuItem(
                  value: 'অভিজ্ঞ (৮+ বছর)',
                  child: Text('অভিজ্ঞ (৮+ বছর)'),
                ),
              ],
              onChanged: editable
                  ? (v) => setState(() {
                      _experienceLevelBn = v;
                      _dirty = true;
                    })
                  : null,
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextField(
              controller: _skillCategory,
              enabled: editable,
              decoration: const InputDecoration(
                labelText: 'এআই/প্রজনন সংশ্লিষ্ট দক্ষতা (ঐচ্ছিক)',
                helperText:
                    'যেমন: গবাদি প্রজনন, গর্ভ নিশ্চিতকরণ, ফলো-আপ সেবা ইত্যাদি',
              ),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextArea(
              controller: _bio,
              enabled: editable,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'সংক্ষিপ্ত পরিচিতি / বর্ণনা',
                alignLabelWithHint: true,
                helperText: 'নিজের অভিজ্ঞতা ও সেধারণ সম্পর্কে লিখুন',
              ),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextField(
              controller: _fee,
              enabled: editable,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'মূল সেবামূল্য (টাকা, ঐচ্ছিক)',
                helperText: 'মৌলিক এআই সেবার মূল্য — সংখ্যায় লিখুন',
              ),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextField(
              controller: _visitFee,
              enabled: editable,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'ভিজিট ফি (টাকা, ঐচ্ছিক)',
                helperText: 'বাড়িতে গিয়ে সেবা দিলে পৃথক ভাড়া থাকলে',
              ),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextField(
              controller: _emergencyFee,
              enabled: editable,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'জরুরি সেবা ফি (টাকা, ঐচ্ছিক)',
                helperText: 'রাত/ছুটির দিন জরুরি কলের জন্য আলাদা মূল্য',
              ),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextArea(
              controller: _followUpPolicy,
              enabled: editable,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'ফলো-আপ নীতি (ঐচ্ছিক)',
                alignLabelWithHint: true,
                helperText: 'গর্ভস্থাপন পরবর্তী পরামর্শ বা ফলো-আপ কীভাবে দেবেন',
              ),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('জরুরি কল গ্রহণ'),
              subtitle: const Text(
                'খামারির জরুরি অনুরোধ দেখতে চাইলে চালু রাখুন',
              ),
              value: _acceptsEmergency,
              onChanged: editable
                  ? (v) => setState(() {
                      _acceptsEmergency = v;
                      _dirty = true;
                    })
                  : null,
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextField(
              controller: _experienceYears,
              enabled: editable,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'মোট অভিজ্ঞতা (বছর, ঐচ্ছিক)',
                helperText: 'পূর্ণ সংখ্যায় — যেমন ৫',
              ),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null;
                final n = int.tryParse(t);
                if (n == null || n < 0 || n > 80) {
                  return '০–৮০ এর মধ্যে সংখ্যা দিন।';
                }
                return null;
              },
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextField(
              controller: _training,
              enabled: editable,
              decoration: const InputDecoration(
                labelText: 'প্রশিক্ষণ প্রতিষ্ঠান',
                helperText: 'যেখান থেকে এআই/পশু প্রজনন প্রশিক্ষণ নিয়েছেন',
              ),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextField(
              controller: _certNo,
              enabled: editable,
              decoration: const InputDecoration(labelText: 'সার্টিফিকেট নম্বর'),
            ),
            SizedBox(height: PraniFormTokens.fieldGap),
            PraniTextArea(
              controller: _certification,
              enabled: editable,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'নিবন্ধন / সার্টিফিকেট বিস্তারিত',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    ),
    ]);
  }

  Widget _buildStepAddress(
    BuildContext context,
    double maxW,
    AiTechnicianProfile p,
    bool editable,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final uniqueAreas = _uniqueCoverageAreas(p);
    final locBanner = ref
        .watch(districtsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.only(bottom: PraniSpacing.sm),
            child: LinearProgressIndicator(minHeight: 3),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(bottom: PraniSpacing.md),
            child: PraniErrorState(
              title: 'এলাকার তালিকা লোড হয়নি',
              message: 'ইন্টারনেট সংযোগ পরীক্ষা করুন। পরে আবার চেষ্টা করুন।',
              compact: true,
              boxed: true,
            ),
          ),
          data: (_) =>
              // Intentional: no extra banner when district list is ready.
              const SizedBox.shrink(),
        );

    return _wizardStepColumn(context, maxW, [
      locBanner,
      KeyedSubtree(
        key: _addressSectionKey,
        child: _buildStepShellV2(
          title: 'কাজের এলাকা ও সেবা এলাকা',
          subtitle:
              'ঠিকানা ও জেলা/উপজেলা/ইউনিয়ন নির্বাচন করুন, তারপর সেবা এলাকা যোগ করুন',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PraniFormCard(
                cardPadding: _wizardFormCardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PraniTextArea(
                      controller: _presentAddress,
                      enabled: editable,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'বর্তমান ঠিকানা',
                      ),
                    ),
                    SizedBox(height: PraniFormTokens.fieldGap),
                    PraniSearchableSelectField<MobileLocationDto>(
                      label: 'জেলা *',
                      hintEmpty: 'জেলা নির্বাচন করুন',
                      enabled: editable,
                      selectedItem: _selectedDistrict,
                      displayBuilder: (d) => d.displayLabelBn,
                      loadItems: () => ref
                          .read(locationRepositoryProvider)
                          .fetchDistricts(),
                      onChanged: editable
                          ? (d) => setState(() {
                              _selectedDistrict = d;
                              _selectedUpazila = null;
                              _selectedUnion = null;
                              _dirty = true;
                            })
                          : null,
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    PraniSearchableSelectField<MobileLocationDto>(
                      label: 'উপজেলা *',
                      hintEmpty: _selectedDistrict == null
                          ? 'প্রথমে জেলা নির্বাচন করুন'
                          : 'উপজেলা নির্বাচন করুন',
                      enabled: editable && _selectedDistrict != null,
                      selectedItem: _selectedUpazila,
                      displayBuilder: (d) => d.displayLabelBn,
                      loadItems: () {
                        final id = _selectedDistrict?.id;
                        if (id == null) {
                          return Future.value(const <MobileLocationDto>[]);
                        }
                        return ref
                            .read(locationRepositoryProvider)
                            .fetchUpazilas(districtId: id);
                      },
                      onChanged: editable
                          ? (d) => setState(() {
                              _selectedUpazila = d;
                              _selectedUnion = null;
                              _dirty = true;
                            })
                          : null,
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    PraniSearchableSelectField<MobileLocationDto>(
                      label: 'ইউনিয়ন / এলাকা (ঐচ্ছিক)',
                      hintEmpty: _selectedUpazila == null
                          ? 'প্রথমে উপজেলা নির্বাচন করুন'
                          : 'ইউনিয়ন নির্বাচন করুন',
                      enabled: editable &&
                          _selectedDistrict != null &&
                          _selectedUpazila != null,
                      selectedItem: _selectedUnion,
                      displayBuilder: (d) => d.displayLabelBn,
                      loadItems: () {
                        final dId = _selectedDistrict?.id;
                        final uId = _selectedUpazila?.id;
                        if (dId == null || uId == null) {
                          return Future.value(const <MobileLocationDto>[]);
                        }
                        return ref
                            .read(locationRepositoryProvider)
                            .fetchUnions(
                              districtId: dId,
                              upazilaId: uId,
                            );
                      },
                      onChanged: editable
                          ? (d) => setState(() {
                              _selectedUnion = d;
                              _dirty = true;
                            })
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PraniSpacing.md),
              PraniFormCard(
                cardPadding: _wizardFormCardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'সেবা এলাকা',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: PraniSpacing.xs),
                    Text(
                      'মোট ${uniqueAreas.length}টি এলাকা নির্বাচিত',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    if (editable) ...[
                      const SizedBox(height: PraniSpacing.md),
                      PraniSecondaryButton(
                        label: 'সেবা এলাকা নির্বাচন করুন',
                        fullWidth: true,
                        minimumHeight: 48,
                        onPressed: _openServiceAreaSelection,
                      ),
                    ],
                    if (uniqueAreas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: PraniSpacing.md),
                        child: Text(
                          'কোনো সেবা এলাকা এখনো যোগ করা হয়নি। বোতামে ট্যাপ করে যোগ করুন।',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                        ),
                      )
                    else ...[
                      const SizedBox(height: PraniSpacing.md),
                      for (final a in uniqueAreas)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${a.district} / ${a.upazila}'),
                          subtitle: (a.unionOrArea ?? '').isEmpty
                              ? null
                              : Text(a.unionOrArea!),
                          trailing: editable
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delArea(a.id),
                                )
                              : null,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget? _documentPreviewWidget(AiTechnicianDocument? doc) {
    if (doc == null) return null;
    return _AiTechnicianServerDocPreview(document: doc);
  }

  Widget _buildStepDocuments(
    BuildContext context,
    double maxW,
    AiTechnicianProfile p,
    bool editable,
  ) {
    Widget uploadSlot(String type, {required bool requiredSlot}) {
      final existing = _docForType(p, type);
      final busy = _inlineUploadingType == type;
      final errBn = _docUploadErrorBn[type];
      final hasPending = _docPendingPath[type] != null;

      late final String status;
      if (busy) {
        status = 'আপলোড চলছে…';
      } else if (errBn != null && hasPending) {
        status = 'ব্যর্থ · $errBn — আবার চেষ্টা করতে বোতাম টিপুন';
      } else if (existing != null) {
        status = 'ফাইল সার্ভারে সংরক্ষিত';
      } else if (hasPending) {
        status = 'নির্বাচিত · আপলোডের জন্য অপেক্ষা';
      } else {
        status = requiredSlot ? 'খালি · আবশ্যক' : 'খালি · ঐচ্ছিক';
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: PraniFormTokens.fieldGap),
        child: PraniUploadCard(
          title: AiTechnicianDocumentTypes.labelBn(type),
          statusLabel: status,
          footnote: _docFootnote(type),
          requiredSlot: requiredSlot,
          enabled: editable && !_submitting,
          isBusy: busy,
          uploadProgress: _uploadProgressFraction,
          preview: _documentSlotPreview(type, existing),
          onUpload: (busy || _submitting)
              ? null
              : () => _uploadDocumentSlot(type),
          onRemove: existing != null && !busy && !_submitting
              ? () => _delDoc(type, existing.id)
              : null,
        ),
      );
    }

    return _wizardStepColumn(context, maxW, [
      _buildStepShellV2(
        title: 'ডকুমেন্ট',
        subtitle: 'ছবি ও প্রয়োজনীয় নথি',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PraniInfoCard(
              title: 'ফাইল সীমা ও ফরম্যাট',
              subtitle:
                  'প্রোফাইল ছবি, এনআইডি সামনে/পিছনে এবং প্রয়োজনীয় নথি দিন। প্রোফাইল ৩ MB, কভার ৫ MB, নথি ৮ MB পর্যন্ত।',
              leadingIcon: const Icon(Icons.info_outline_rounded, size: 22),
            ),
            const SizedBox(height: PraniSpacing.md),
            for (final t in _documentStepSlots)
              uploadSlot(t, requiredSlot: t == 'NID_FRONT' || t == 'NID_BACK'),
          ],
        ),
      ),
    ]);
  }

  Widget _buildStepReview(
    BuildContext context,
    double maxW,
    AiTechnicianProfile p,
    bool editable,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bodyStyle = PraniTextStyles.body(scheme, textTheme);
    final issuesByGroup = _reviewIssuesByGroup(p);

    String phoneLine() {
      final local = _phone.text.trim();
      if (local.isNotEmpty) return local;
      final s = p.phone?.trim();
      if (s != null && s.isNotEmpty) {
        return '$s (প্রোফাইলে সংরক্ষিত)';
      }
      return '—';
    }

    Widget groupCard(
      String title,
      int editStep,
      List<String> issues, {
      required List<Widget> lines,
    }) {
      final hasIssues = issues.isNotEmpty;
      return Padding(
        padding: const EdgeInsets.only(bottom: PraniSpacing.md),
        child: PraniFormCard(
          cardPadding: _wizardFormCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasIssues)
                Container(
                  margin: const EdgeInsets.only(bottom: PraniSpacing.sm),
                  padding: const EdgeInsets.all(PraniSpacing.md),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: scheme.onErrorContainer,
                            size: 22,
                          ),
                          const SizedBox(width: PraniSpacing.sm),
                          Text(
                            'আবশ্যক তথ্য',
                            style: textTheme.titleSmall?.copyWith(
                              color: scheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      for (final line in issues)
                        Padding(
                          padding: const EdgeInsets.only(top: PraniSpacing.xs),
                          child: Text(
                            line,
                            style: bodyStyle.copyWith(
                              color: scheme.onErrorContainer,
                              height: 1.35,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: editable ? () => _goToStep(editStep) : null,
                    child: const Text('সম্পাদনা করুন'),
                  ),
                ],
              ),
              const SizedBox(height: PraniSpacing.xs),
              ...lines,
            ],
          ),
        ),
      );
    }

    return _wizardStepColumn(context, maxW, [
      _buildStepShellV2(
        title: 'রিভিউ ও জমা',
        subtitle: 'এক নজরে দেখে নিশ্চিত করুন',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (editable && _submitBlockedReason(p) != null)
              Padding(
                padding: const EdgeInsets.only(bottom: PraniSpacing.md),
                child: PraniFormCard(
                  cardPadding: _wizardFormCardPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: scheme.error, size: 22),
                      const SizedBox(width: PraniSpacing.sm),
                      Expanded(
                        child: Text(
                          _submitBlockedReason(p)!,
                          style: bodyStyle.copyWith(color: scheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            PraniFormCard(
        cardPadding: _wizardFormCardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _dirty ? Icons.edit_note_rounded : Icons.cloud_done_outlined,
              color: _dirty ? scheme.tertiary : scheme.primary,
              size: 22,
            ),
            const SizedBox(width: PraniSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'খসড়ার অবস্থা',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.xs),
                  Text(
                    _dirty
                        ? 'নতুন পরিবর্তন আছে — “পরবর্তী” চাপলে খসড়া স্বয়ংক্রিয় সংরক্ষিত হয়।'
                        : 'খসড়া সার্ভারের সাথে মিলে আছে।',
                    style: bodyStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: PraniSpacing.sm),
      groupCard(
        'ব্যক্তিগত তথ্য',
        0,
        issuesByGroup['personal']!,
        lines: [
          Text(
            'নাম: ${_displayName.text.trim().isEmpty ? '—' : _displayName.text.trim()}',
            style: bodyStyle,
          ),
          Text('ফোন: ${phoneLine()}', style: bodyStyle),
          Text(
            'ইমেইল: ${_email.text.trim().isEmpty ? '—' : _email.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'এনআইডি: ${_nid.text.trim().isEmpty ? '—' : _nid.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'জন্মতারিখ: ${_dob.text.trim().isEmpty ? '—' : _dobDisplayLabel()}',
            style: bodyStyle,
          ),
          Text('লিঙ্গ: ${_genderLabelBn(_gender)}', style: bodyStyle),
        ],
      ),
      groupCard(
        'নথিপত্র',
        3,
        issuesByGroup['documents']!,
        lines: [
          Text(
            'আপলোড করা নথি: ${p.documents.length}টি',
            style: bodyStyle.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: PraniSpacing.sm),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _documentStepSlots.length,
              separatorBuilder: (context, _) =>
                  const SizedBox(width: PraniSpacing.sm),
              itemBuilder: (ctx, i) {
                final type = _documentStepSlots[i];
                final existing = _docForType(p, type);
                final preview = _documentSlotPreview(type, existing);
                return SizedBox(
                  width: 108,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              preview ??
                              ColoredBox(
                                color: scheme.surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: scheme.onSurfaceVariant,
                                    size: 28,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.xs),
                      Text(
                        AiTechnicianDocumentTypes.labelBn(type),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(height: 1.2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (p.documents.isNotEmpty) ...[
            const SizedBox(height: PraniSpacing.sm),
            for (final d in p.documents)
              Text(
                '· ${AiTechnicianDocumentTypes.labelBn(d.type)} — ${d.title}',
                style: bodyStyle,
              ),
          ],
        ],
      ),
      groupCard(
        'পেশাগত তথ্য',
        2,
        issuesByGroup['professional']!,
        lines: [
          Text(
            'অভিজ্ঞতার স্তর: ${_experienceLevelBn ?? '—'}',
            style: bodyStyle,
          ),
          Text(
            'এআই/প্রজনন দক্ষতা: ${_skillCategory.text.trim().isEmpty ? '—' : _skillCategory.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'পরিচিতি: ${_bio.text.trim().isEmpty ? '—' : _bio.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'অভিজ্ঞতা (বছর): ${_experienceYears.text.trim().isEmpty ? '—' : _experienceYears.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'প্রশিক্ষণ: ${_training.text.trim().isEmpty ? '—' : _training.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'সার্টিফিকেট নং: ${_certNo.text.trim().isEmpty ? '—' : _certNo.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'নিবন্ধন / সার্টিফিকেট: ${_certification.text.trim().isEmpty ? '—' : _certification.text.trim()}',
            style: bodyStyle,
          ),
        ],
      ),
      groupCard(
        'ঠিকানা ও সেবা এলাকা',
        1,
        issuesByGroup['address']!,
        lines: [
          Text(
            'ঠিকানা: ${_presentAddress.text.trim().isEmpty ? '—' : _presentAddress.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'জেলা/উপজেলা: ${_selectedDistrict == null || _selectedUpazila == null ? '—' : '${_selectedDistrict!.displayLabelBn} / ${_selectedUpazila!.displayLabelBn}'}',
            style: bodyStyle,
          ),
          if (_selectedUnion != null)
            Text(
              'ইউনিয়ন: ${_selectedUnion!.displayLabelBn}',
              style: bodyStyle,
            ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            'নির্বাচিত সেবা এলাকা: ${_uniqueCoverageAreas(p).length}টি',
            style: bodyStyle.copyWith(fontWeight: FontWeight.w500),
          ),
          for (final a in _uniqueCoverageAreas(p))
            Text(
              '· ${a.district} / ${a.upazila}${(a.unionOrArea ?? '').isEmpty ? '' : ' — ${a.unionOrArea}'}',
              style: bodyStyle,
            ),
        ],
      ),
      groupCard(
        'ফি ও নীতি',
        2,
        issuesByGroup['fees']!,
        lines: [
          Text(
            'মূল সেবামূল্য: ${_fee.text.trim().isEmpty ? '—' : _fee.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'ভিজিট ফি: ${_visitFee.text.trim().isEmpty ? '—' : _visitFee.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'জরুরি সেবা ফি: ${_emergencyFee.text.trim().isEmpty ? '—' : _emergencyFee.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'ফলো-আপ নীতি: ${_followUpPolicy.text.trim().isEmpty ? '—' : _followUpPolicy.text.trim()}',
            style: bodyStyle,
          ),
          Text(
            'জরুরি কল গ্রহণ: ${_acceptsEmergency ? 'হ্যাঁ' : 'না'}',
            style: bodyStyle,
          ),
        ],
      ),
      if (editable)
        PraniFormCard(
          cardPadding: _wizardFormCardPadding,
          child: CheckboxListTile(
            value: _reviewDeclarationAccepted,
            onChanged: _submitting
                ? null
                : (v) =>
                      setState(() => _reviewDeclarationAccepted = v ?? false),
            title: const Text('আমি নিশ্চিত করছি যে দেওয়া তথ্য সঠিক'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    ),
  ),
    ]);
  }

  String _genderLabelBn(String? g) {
    switch (g) {
      case 'MALE':
        return 'পুরুষ';
      case 'FEMALE':
        return 'নারী';
      case 'OTHER':
        return 'অন্যান্য';
      case 'UNKNOWN':
        return 'বলতে চাই না';
      default:
        return 'নির্বাচন করুন';
    }
  }
}

String _absoluteApiMediaUrl(String apiBase, String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  final low = t.toLowerCase();
  if (low.startsWith('http://') || low.startsWith('https://')) return t;
  final b = apiBase.trimRight();
  if (t.startsWith('/')) {
    final u = Uri.parse(b.contains('://') ? b : 'https://$b');
    final port = u.hasPort ? ':${u.port}' : '';
    return '${u.scheme}://${u.host}$port$t';
  }
  return b.endsWith('/') ? '$b$t' : '$b/$t';
}

bool _bytesLooksPdf(Uint8List data) {
  if (data.length < 4) return false;
  return String.fromCharCodes(data.sublist(0, 4)) == '%PDF';
}

bool _bytesLooksLikeRasterImage(Uint8List data) {
  if (data.length < 3) return false;
  if (data[0] == 0xff && data[1] == 0xd8) return true;
  if (data.length >= 8 &&
      data[0] == 0x89 &&
      data[1] == 0x50 &&
      data[2] == 0x4e &&
      data[3] == 0x47) {
    return true;
  }
  if (data.length >= 12 &&
      data[0] == 0x52 &&
      data[1] == 0x49 &&
      data[2] == 0x46 &&
      data[3] == 0x46) {
    return true;
  }
  return false;
}

/// Loads `/api/mobile/uploads/:id` with session [Dio] (Bearer), since some
/// technician document purposes are not public for `Image.network`.
class _AiTechnicianServerDocPreview extends ConsumerStatefulWidget {
  const _AiTechnicianServerDocPreview({required this.document});

  final AiTechnicianDocument document;

  @override
  ConsumerState<_AiTechnicianServerDocPreview> createState() =>
      _AiTechnicianServerDocPreviewState();
}

class _AiTechnicianServerDocPreviewState
    extends ConsumerState<_AiTechnicianServerDocPreview> {
  Uint8List? _bytes;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant _AiTechnicianServerDocPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id ||
        oldWidget.document.uploadedFileId != widget.document.uploadedFileId ||
        oldWidget.document.fileUrl != widget.document.fileUrl) {
      _bytes = null;
      _error = null;
      _loading = true;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final doc = widget.document;
    final dio = ref.read(apiClientProvider).dio;
    final base = ref.read(apiClientProvider).baseUrl;

    try {
      final id = doc.uploadedFileId?.trim();
      if (id != null && id.isNotEmpty) {
        final res = await dio.get<List<int>>(
          'api/mobile/uploads/$id',
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            headers: <String, dynamic>{Headers.acceptHeader: '*/*'},
          ),
        );
        final code = res.statusCode ?? 0;
        if (code >= 200 && code < 300) {
          final data = Uint8List.fromList(res.data ?? const <int>[]);
          if (!mounted) return;
          setState(() {
            _bytes = data;
            _error = null;
            _loading = false;
          });
          return;
        }
      }

      final rawUrl = doc.fileUrl?.trim();
      if (rawUrl != null && rawUrl.isNotEmpty) {
        final absolute = _absoluteApiMediaUrl(base, rawUrl);
        final res = await dio.get<List<int>>(
          absolute,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            headers: <String, dynamic>{Headers.acceptHeader: '*/*'},
          ),
        );
        final code = res.statusCode ?? 0;
        if (code >= 200 && code < 300) {
          final data = Uint8List.fromList(res.data ?? const <int>[]);
          if (!mounted) return;
          setState(() {
            _bytes = data;
            _error = null;
            _loading = false;
          });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _bytes = null;
        _error = StateError('no_body');
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _bytes = null;
        _loading = false;
      });
    }
  }

  bool _mimeLooksPdf(String? mime, String title) {
    final m = mime?.toLowerCase() ?? '';
    if (m.contains('pdf')) return true;
    return title.toLowerCase().endsWith('.pdf');
  }

  bool _mimeLooksImage(String? mime, String title) {
    final m = mime?.toLowerCase() ?? '';
    if (m.startsWith('image/')) return true;
    final l = title.toLowerCase();
    return l.endsWith('.jpg') ||
        l.endsWith('.jpeg') ||
        l.endsWith('.png') ||
        l.endsWith('.webp');
  }

  Widget _fallbackCard(
    BuildContext context, {
    required String detailLine,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final doc = widget.document;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(PraniSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insert_drive_file_outlined, color: scheme.primary),
                const SizedBox(width: PraniSpacing.sm),
                Expanded(
                  child: Text(
                    doc.title.trim().isEmpty ? 'নথি' : doc.title.trim(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              'ফাইল সার্ভারে সংরক্ষিত',
              style: PraniTextStyles.bodySmall(
                scheme,
                Theme.of(context).textTheme,
              ).copyWith(color: scheme.onSurfaceVariant),
            ),
            Text(
              detailLine,
              style: PraniTextStyles.caption(
                scheme,
                Theme.of(context).textTheme,
              ).copyWith(color: scheme.onSurfaceVariant, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    if (_loading) {
      return SizedBox(
        height: 96,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (_error != null || _bytes == null || _bytes!.isEmpty) {
      return _fallbackCard(
        context,
        detailLine: 'প্রিভিউ পাওয়া যায়নি',
      );
    }

    final data = _bytes!;
    final mime = doc.mimeType;
    final title = doc.title;

    if (_mimeLooksPdf(mime, title) || _bytesLooksPdf(data)) {
      return _fallbackCard(
        context,
        detailLine: 'পিডিএফ ফাইল · প্রিভিউ নেই',
      );
    }

    final looksImage =
        _mimeLooksImage(mime, title) ||
        _bytesLooksLikeRasterImage(data);

    if (looksImage) {
      return Image.memory(
        data,
        height: 96,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _fallbackCard(
          context,
          detailLine: 'প্রিভিউ পাওয়া যায়নি',
        ),
      );
    }

    return _fallbackCard(
      context,
      detailLine: 'প্রিভিউ পাওয়া যায়নি',
    );
  }
}
