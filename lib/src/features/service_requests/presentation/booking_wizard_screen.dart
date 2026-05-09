import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/constants/pd_spacing.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_app_card.dart';
import 'package:pranidoctor_mobile/src/core/widgets/pd_text_field.dart';
import 'package:pranidoctor_mobile/src/features/animals/application/animals_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/application/provider_finder_providers.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_list_query.dart';
import 'package:pranidoctor_mobile/src/features/providers/data/provider_models.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/booking_submit_helpers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/domain/booking_urgency.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/presentation/booking_success_screen.dart';

/// Multi-step booking: service → animal → area → provider → problem → urgency → time → review.
class BookingWizardScreen extends ConsumerStatefulWidget {
  const BookingWizardScreen({super.key, this.initialServiceType});

  /// Optional preset from `?preset=SERVICE_ENUM_NAME`.
  final ServiceRequestType? initialServiceType;

  static const routePath = '/booking/new';
  static const routeName = 'bookingNew';

  @override
  ConsumerState<BookingWizardScreen> createState() =>
      _BookingWizardScreenState();
}

class _BookingWizardScreenState extends ConsumerState<BookingWizardScreen> {
  final PageController _page = PageController();
  int _index = 0;
  static const int _pageCount = 8;
  bool _submitting = false;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingDraftProvider.notifier).reset();
      final preset = widget.initialServiceType;
      if (preset != null) {
        ref.read(bookingDraftProvider.notifier).applyPresetServiceType(preset);
      }
    });
  }

  String? _validationMessage(BookingDraft d) {
    switch (_index) {
      case 0:
        if (d.serviceType == null) return 'সেবার ধরন নির্বাচন করুন';
      case 1:
        if (d.animalId == null) return 'একটি পশু নির্বাচন করুন';
      case 2:
        final t = d.serviceType;
        if (t == null) return 'সেবার ধরন নির্বাচন করুন';
        if (bookingNeedsGeo(t) &&
            !bookingHasValidLocation(
              serviceType: t,
              selectedAreaSlug: d.selectedAreaSlug,
              locationDetail: d.locationDetail,
            )) {
          return 'এলাকা বা ঠিকানার বর্ণনা দিন';
        }
      case 3:
        break;
      case 4:
        if (d.problemOrSymptom.trim().isEmpty) {
          return 'সমস্যা বা লক্ষণ লিখুন';
        }
      case 5:
        if (d.urgency == null) return 'জরুরিতা নির্বাচন করুন';
      case 6:
        final t = d.serviceType;
        if (t == ServiceRequestType.ONLINE_CONSULTATION_LATER &&
            d.preferredTime.trim().isEmpty) {
          return 'পছন্দের সময় লিখুন';
        }
    }
    return null;
  }

  String? _validateAll(BookingDraft d) {
    if (d.serviceType == null) return 'সেবার ধরন নির্বাচন করুন';
    if (d.animalId == null) return 'একটি পশু নির্বাচন করুন';
    final t = d.serviceType!;
    if (bookingNeedsGeo(t) &&
        !bookingHasValidLocation(
          serviceType: t,
          selectedAreaSlug: d.selectedAreaSlug,
          locationDetail: d.locationDetail,
        )) {
      return 'এলাকা বা ঠিকানার বর্ণনা দিন';
    }
    if (d.problemOrSymptom.trim().isEmpty) return 'সমস্যা বা লক্ষণ লিখুন';
    if (d.urgency == null) return 'জরুরিতা নির্বাচন করুন';
    if (t == ServiceRequestType.ONLINE_CONSULTATION_LATER &&
        d.preferredTime.trim().isEmpty) {
      return 'পছন্দের সময় লিখুন';
    }
    return null;
  }

  bool _showEmergencyNotice(BookingDraft d) {
    return d.urgency == BookingUrgency.emergency ||
        d.serviceType == ServiceRequestType.EMERGENCY_DOCTOR;
  }

  Future<void> _next() async {
    final d = ref.read(bookingDraftProvider);
    final err = _validationMessage(d);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (_index < _pageCount - 1) {
      await _page.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() {
    if (_index > 0) {
      _page.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final d = ref.read(bookingDraftProvider);
    final err = _validateAll(d);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    if (_showEmergencyNotice(d)) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('জরুরি অনুরোধ'),
          content: const Text(
            'এটি জরুরি চিকিৎসা সংক্রান্ত অনুরোধ। প্রাণীর অবস্থা গুরুতর হলে স্থানীয় ভেটেরিনারি ক্লিনিকে যোগাযোগ করুন। চালিয়ে যাবেন?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('পিছনে'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('জমা দিন'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    final type = d.serviceType!;
    final slug = type.slug;

    List<ServiceCategoryOption> cats;
    try {
      cats = await ref.read(serviceCategoriesProvider.future);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ক্যাটাগরি লোড হয়নি: $e')));
      return;
    }

    String? categoryId;
    for (final c in cats) {
      if (c.slug == slug) {
        categoryId = c.id;
        break;
      }
    }
    if (categoryId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সার্ভারে প্রয়োজনীয় সেবা ক্যাটাগরি পাওয়া যায়নি'),
        ),
      );
      return;
    }

    final urgency = d.urgency!;
    final composedLoc = bookingLocationTextForSubmit(
      serviceType: type,
      selectedAreaSlug: d.selectedAreaSlug,
      locationDetailTrimmed: d.locationDetail.trim(),
    );

    final mergedDesc = bookingMergedDescription(
      urgency: urgency,
      userExtraDescription: d.description,
      preferredProviderName: d.preferredProviderDisplayName,
      preferredProviderKind: d.preferredProviderKind,
    );

    final body = <String, dynamic>{
      'animalId': d.animalId,
      'serviceCategoryId': categoryId,
      'serviceType': type.name,
      'problemOrSymptom': d.problemOrSymptom.trim(),
      if (mergedDesc != null && mergedDesc.isNotEmpty)
        'description': mergedDesc,
      if (composedLoc.isNotEmpty) 'locationText': composedLoc,
      if (d.preferredTime.trim().isNotEmpty)
        'preferredTime': d.preferredTime.trim(),
    };

    setState(() => _submitting = true);
    try {
      final repo = ref.read(serviceRequestRepositoryProvider);
      final created = await repo.create(body);
      if (!mounted) return;
      ref.invalidate(serviceRequestsListProvider);
      ref.read(bookingDraftProvider.notifier).reset();
      context.pushReplacement(BookingSuccessScreen.routePath, extra: created);
    } on ServiceRequestApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final hPad = pdScreenPadding(context).horizontal;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('নতুন অনুরোধ (${_index + 1}/$_pageCount)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _back,
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: (_index + 1) / _pageCount),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _ServiceTypeStep(paddingH: hPad),
                  _AnimalStep(paddingH: hPad),
                  _AreaStep(paddingH: hPad),
                  _ProviderStep(paddingH: hPad),
                  _ProblemStep(paddingH: hPad),
                  _UrgencyStep(paddingH: hPad),
                  _PreferredTimeStep(paddingH: hPad),
                  _ReviewStep(
                    paddingH: hPad,
                    draft: draft,
                    submitting: _submitting,
                    showEmergencyNotice: _showEmergencyNotice(draft),
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
              child: Row(
                children: [
                  if (_index < _pageCount - 1)
                    Expanded(
                      child: FilledButton(
                        onPressed: _next,
                        child: const Text('পরবর্তী'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Steps ---

class _ServiceTypeStep extends ConsumerWidget {
  const _ServiceTypeStep({required this.paddingH});

  final double paddingH;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(paddingH, 16, paddingH, 24),
      children: [
        Text('কোন সেবা দরকার?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'একটি বেছে নিন। জরুরি সেবায় অতিরিক্ত সতর্কতা প্রয়োজন।',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        for (final t in ServiceRequestType.values) ...[
          if (t == ServiceRequestType.EMERGENCY_DOCTOR)
            const _EmergencyInlineNotice(),
          PdAppCard(
            useShadow: false,
            onTap: () =>
                ref.read(bookingDraftProvider.notifier).setServiceType(t),
            padding: const EdgeInsets.all(PdSpacing.md),
            child: Row(
              children: [
                Icon(
                  _iconForType(t),
                  color: draft.serviceType == t
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: PdSpacing.md),
                Expanded(
                  child: Text(
                    t.labelBn,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: draft.serviceType == t ? scheme.primary : null,
                    ),
                  ),
                ),
                if (draft.serviceType == t)
                  Icon(Icons.check_circle, color: scheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  IconData _iconForType(ServiceRequestType t) {
    return switch (t) {
      ServiceRequestType.DOCTOR_HOME_VISIT => Icons.medical_services_outlined,
      ServiceRequestType.EMERGENCY_DOCTOR => Icons.emergency_outlined,
      ServiceRequestType.AI_SERVICE => Icons.smart_toy_outlined,
      ServiceRequestType.ONLINE_CONSULTATION_LATER => Icons.video_call_outlined,
    };
  }
}

class _EmergencyInlineNotice extends StatelessWidget {
  const _EmergencyInlineNotice();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'জরুরি ডাক্তার শুধু গুরুতর অবস্থার জন্য। প্রয়োজনে নিকটস্থ ক্লিনিকে যান।',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalStep extends ConsumerWidget {
  const _AnimalStep({required this.paddingH});

  final double paddingH;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animals = ref.watch(animalsListProvider);
    final draft = ref.watch(bookingDraftProvider);
    final scheme = Theme.of(context).colorScheme;

    return animals.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingH),
          child: Text('পশু লোড হয়নি: $e', textAlign: TextAlign.center),
        ),
      ),
      data: (list) {
        final active = list.where((a) => a.active).toList();
        if (active.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingH),
              child: const Text(
                'কোনো সক্রিয় পশু নেই। “আমার পশু” ট্যাবে প্রোফাইল যোগ করুন।',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(paddingH, 16, paddingH, 24),
          itemCount: active.length,
          itemBuilder: (context, i) {
            final a = active[i];
            final selected = draft.animalId == a.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: selected
                  ? scheme.primaryContainer.withValues(alpha: 0.35)
                  : null,
              child: ListTile(
                title: Text(a.name),
                subtitle: Text(a.species),
                trailing: selected
                    ? Icon(Icons.check_circle, color: scheme.primary)
                    : null,
                onTap: () =>
                    ref.read(bookingDraftProvider.notifier).setAnimalId(a.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _AreaStep extends ConsumerStatefulWidget {
  const _AreaStep({required this.paddingH});

  final double paddingH;

  @override
  ConsumerState<_AreaStep> createState() => _AreaStepState();
}

class _AreaStepState extends ConsumerState<_AreaStep> {
  late final TextEditingController _detailCtrl;

  @override
  void initState() {
    super.initState();
    _detailCtrl = TextEditingController(
      text: ref.read(bookingDraftProvider).locationDetail,
    );
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final type = draft.serviceType;
    final scheme = Theme.of(context).colorScheme;

    final geo = type != null && bookingNeedsGeo(type);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(widget.paddingH, 16, widget.paddingH, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            geo ? 'এলাকা ও অবস্থান' : 'অবস্থান (ঐচ্ছিক)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            geo
                ? 'এলাকা বেছে নিন এবং বিস্তারিত ঠিকানা দিন। অন্তত একটি তথ্য প্রয়োজন।'
                : 'অনলাইন পরামর্শের জন্য ঠিকানা ঐচ্ছিক। পরামর্শ শীঘ্রই চালু হবে।',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text('এলাকার ধরন', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...BookingAreaPresets.choices.map((e) {
            final selected = draft.selectedAreaSlug == e.slug;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected
                    ? scheme.primaryContainer.withValues(alpha: 0.4)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => ref
                      .read(bookingDraftProvider.notifier)
                      .setSelectedAreaSlug(e.slug),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.labelBn)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          PdTextField(
            controller: _detailCtrl,
            labelText: geo
                ? 'বিস্তারিত ঠিকানা / গ্রাম / ল্যান্ডমার্ক'
                : 'ঠিকানা (ঐচ্ছিক)',
            hintText: 'যেমন: ইউনিয়ন পরিষদের পাশে…',
            maxLines: 4,
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setLocationDetail(v),
          ),
        ],
      ),
    );
  }
}

class _ProviderStep extends ConsumerStatefulWidget {
  const _ProviderStep({required this.paddingH});

  final double paddingH;

  @override
  ConsumerState<_ProviderStep> createState() => _ProviderStepState();
}

class _ProviderStepState extends ConsumerState<_ProviderStep> {
  int _reloadGen = 0;

  Future<({List<DoctorSummary>? doctors, List<TechnicianSummary>? techs})>
  _fetch(BookingDraft d) async {
    final type = d.serviceType;
    if (type == null) {
      return (
        doctors: null as List<DoctorSummary>?,
        techs: null as List<TechnicianSummary>?,
      );
    }
    final repo = ref.read(providerFinderRepositoryProvider);
    final area = d.selectedAreaSlug.isNotEmpty ? d.selectedAreaSlug : null;
    try {
      if (type == ServiceRequestType.AI_SERVICE) {
        final r = await repo.listTechnicians(
          ProviderListQuery(
            areaSlug: area,
            aiTechnicianService: true,
            limit: 40,
          ),
        );
        return (doctors: null as List<DoctorSummary>?, techs: r.technicians);
      }
      if (type == ServiceRequestType.ONLINE_CONSULTATION_LATER) {
        return (
          doctors: null as List<DoctorSummary>?,
          techs: null as List<TechnicianSummary>?,
        );
      }
      final r = await repo.listDoctors(
        ProviderListQuery(
          areaSlug: area,
          homeVisit: type == ServiceRequestType.DOCTOR_HOME_VISIT ? true : null,
          emergency: type == ServiceRequestType.EMERGENCY_DOCTOR ? true : null,
          limit: 40,
        ),
      );
      return (doctors: r.doctors, techs: null as List<TechnicianSummary>?);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final type = draft.serviceType;
    final scheme = Theme.of(context).colorScheme;

    if (type == ServiceRequestType.ONLINE_CONSULTATION_LATER) {
      return ListView(
        padding: EdgeInsets.fromLTRB(widget.paddingH, 16, widget.paddingH, 24),
        children: [
          Icon(Icons.info_outline, size: 48, color: scheme.primary),
          const SizedBox(height: 12),
          Text('অনলাইন পরামর্শ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'এই মুহূর্তে ভিডিও কল চালু নয়। অনুরোধ জমা দিলে পরে যোগাযোগ করা হবে। নির্দিষ্ট ডাক্তার বেছে নেওয়ার প্রয়োজন নেই।',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return FutureBuilder<
      ({List<DoctorSummary>? doctors, List<TechnicianSummary>? techs})
    >(
      key: ValueKey(
        Object.hash(draft.serviceType, draft.selectedAreaSlug, _reloadGen),
      ),
      future: _fetch(draft),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return ListView(
            padding: EdgeInsets.fromLTRB(
              widget.paddingH,
              24,
              widget.paddingH,
              24,
            ),
            children: [
              Icon(Icons.cloud_off_outlined, color: scheme.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'প্রদানকারী তালিকা লোড হয়নি',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${snap.error}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => setState(() => _reloadGen++),
                child: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          );
        }
        final data = snap.data!;
        final doctors = data.doctors;
        final techs = data.techs;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            widget.paddingH,
            16,
            widget.paddingH,
            24,
          ),
          children: [
            Text(
              'পছন্দের প্রদানকারী (ঐচ্ছিক)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'একজন বেছে নিতে পারেন বা এড়িয়ে যান। নির্দিষ্ট নাম অনুরোধের বিবরণে যুক্ত হবে।',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (draft.preferredProviderId != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => ref
                      .read(bookingDraftProvider.notifier)
                      .clearPreferredProvider(),
                  child: const Text('পছন্দ সরান'),
                ),
              ),
            if (doctors != null)
              ...doctors.map((d) {
                final sel =
                    draft.preferredProviderId == d.id &&
                    draft.preferredProviderKind == ProviderKind.doctor;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: sel
                      ? scheme.primaryContainer.withValues(alpha: 0.35)
                      : null,
                  child: ListTile(
                    title: Text(d.name),
                    subtitle: Text(
                      d.areaText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: sel
                        ? Icon(Icons.check_circle, color: scheme.primary)
                        : null,
                    onTap: () => ref
                        .read(bookingDraftProvider.notifier)
                        .setPreferredProvider(
                          id: d.id,
                          kind: ProviderKind.doctor,
                          displayName: d.name,
                        ),
                  ),
                );
              }),
            if (techs != null)
              ...techs.map((t) {
                final sel =
                    draft.preferredProviderId == t.id &&
                    draft.preferredProviderKind == ProviderKind.aiTechnician;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: sel
                      ? scheme.primaryContainer.withValues(alpha: 0.35)
                      : null,
                  child: ListTile(
                    title: Text(t.name),
                    subtitle: Text(
                      t.areaText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: sel
                        ? Icon(Icons.check_circle, color: scheme.primary)
                        : null,
                    onTap: () => ref
                        .read(bookingDraftProvider.notifier)
                        .setPreferredProvider(
                          id: t.id,
                          kind: ProviderKind.aiTechnician,
                          displayName: t.name,
                        ),
                  ),
                );
              }),
            if ((doctors?.isEmpty ?? true) && (techs?.isEmpty ?? true))
              Text(
                'কোনো প্রদানকারী পাওয়া যায়নি। পরবর্তী ধাপে যেতে পারেন।',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProblemStep extends ConsumerStatefulWidget {
  const _ProblemStep({required this.paddingH});

  final double paddingH;

  @override
  ConsumerState<_ProblemStep> createState() => _ProblemStepState();
}

class _ProblemStepState extends ConsumerState<_ProblemStep> {
  late final TextEditingController _problem;
  late final TextEditingController _extra;

  @override
  void initState() {
    super.initState();
    final d = ref.read(bookingDraftProvider);
    _problem = TextEditingController(text: d.problemOrSymptom);
    _extra = TextEditingController(text: d.description);
  }

  @override
  void dispose() {
    _problem.dispose();
    _extra.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(widget.paddingH, 16, widget.paddingH, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'সমস্যা ও লক্ষণ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          PdTextField(
            controller: _problem,
            labelText: 'সমস্যা / লক্ষণ (প্রয়োজনীয়)',
            hintText: 'যেমন: জ্বর, খাবার খাচ্ছে না…',
            maxLines: 5,
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setProblem(v),
          ),
          const SizedBox(height: 20),
          PdTextField(
            controller: _extra,
            labelText: 'অতিরিক্ত বিবরণ (ঐচ্ছিক)',
            hintText: 'ইতিহাস, ওষুধ, আগের চিকিৎসা…',
            maxLines: 4,
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setDescription(v),
          ),
        ],
      ),
    );
  }
}

class _UrgencyStep extends ConsumerWidget {
  const _UrgencyStep({required this.paddingH});

  final double paddingH;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(paddingH, 16, paddingH, 24),
      children: [
        Text('জরুরিতার মাত্রা', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'চিকিৎসা প্রয়োজনের তাড়াহুড়ো বোঝাতে সাহায্য করে।',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        for (final u in BookingUrgency.values) ...[
          if (u == BookingUrgency.emergency)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EmergencyInlineNotice(),
            ),
          PdAppCard(
            useShadow: false,
            onTap: () => ref.read(bookingDraftProvider.notifier).setUrgency(u),
            padding: const EdgeInsets.all(PdSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    u.labelBn,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: draft.urgency == u ? scheme.primary : null,
                    ),
                  ),
                ),
                if (draft.urgency == u)
                  Icon(Icons.check_circle, color: scheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _PreferredTimeStep extends ConsumerStatefulWidget {
  const _PreferredTimeStep({required this.paddingH});

  final double paddingH;

  @override
  ConsumerState<_PreferredTimeStep> createState() => _PreferredTimeStepState();
}

class _PreferredTimeStepState extends ConsumerState<_PreferredTimeStep> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: ref.read(bookingDraftProvider).preferredTime,
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(bookingDraftProvider).serviceType;
    final online = type == ServiceRequestType.ONLINE_CONSULTATION_LATER;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(widget.paddingH, 16, widget.paddingH, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            online ? 'পছন্দের সময় (প্রয়োজনীয়)' : 'পছন্দের সময় (ঐচ্ছিক)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            online
                ? 'অনলাইন পরামর্শের জন্য সময় উল্লেখ করুন। সেবা শীঘ্রই চালু হবে।'
                : 'কখন পরিদর্শন বা যোগাযোগ সুবিধাজনক তা লিখুন।',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          PdTextField(
            controller: _c,
            hintText: 'উদা: আগামীকাল সকাল ১০টা',
            maxLines: 2,
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setPreferredTime(v),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep({
    required this.paddingH,
    required this.draft,
    required this.submitting,
    required this.showEmergencyNotice,
    required this.onSubmit,
  });

  final double paddingH;
  final BookingDraft draft;
  final bool submitting;
  final bool showEmergencyNotice;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animals = ref.watch(animalsListProvider);
    final animalName = animals.maybeWhen(
      data: (l) {
        try {
          return l.firstWhere((a) => a.id == draft.animalId).name;
        } catch (_) {
          return draft.animalId;
        }
      },
      orElse: () => draft.animalId,
    );

    final type = draft.serviceType;
    final composedLoc = type != null
        ? bookingLocationTextForSubmit(
            serviceType: type,
            selectedAreaSlug: draft.selectedAreaSlug,
            locationDetailTrimmed: draft.locationDetail.trim(),
          )
        : '';

    return ListView(
      padding: EdgeInsets.fromLTRB(paddingH, 16, paddingH, 24),
      children: [
        Text('যাচাই করুন', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (showEmergencyNotice) ...[
          const _EmergencyInlineNotice(),
          const SizedBox(height: 12),
        ],
        _ReviewRow('পশু', animalName ?? '—'),
        _ReviewRow('সেবা', draft.serviceType?.labelBn ?? '—'),
        _ReviewRow('এলাকা / ঠিকানা', composedLoc.isEmpty ? '—' : composedLoc),
        _ReviewRow(
          'পছন্দের প্রদানকারী',
          draft.preferredProviderDisplayName ?? '—',
        ),
        _ReviewRow(
          'সমস্যা',
          draft.problemOrSymptom.trim().isEmpty ? '—' : draft.problemOrSymptom,
        ),
        _ReviewRow(
          'অতিরিক্ত বিবরণ',
          draft.description.trim().isEmpty ? '—' : draft.description,
        ),
        _ReviewRow('জরুরিতা', draft.urgency?.labelBn ?? '—'),
        _ReviewRow(
          'পছন্দের সময়',
          draft.preferredTime.trim().isEmpty ? '—' : draft.preferredTime,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: submitting ? null : onSubmit,
          child: submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('জমা দিন'),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
