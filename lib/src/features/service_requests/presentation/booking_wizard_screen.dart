import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/animals/application/animals_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/application/service_requests_providers.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_model.dart';
import 'package:pranidoctor_mobile/src/features/service_requests/data/service_request_repository.dart';

/// Multi-step booking flow (animal → type → … → submit).
class BookingWizardScreen extends ConsumerStatefulWidget {
  const BookingWizardScreen({super.key});

  static const routePath = '/booking/new';
  static const routeName = 'bookingNew';

  @override
  ConsumerState<BookingWizardScreen> createState() =>
      _BookingWizardScreenState();
}

class _BookingWizardScreenState extends ConsumerState<BookingWizardScreen> {
  final PageController _page = PageController();
  int _index = 0;
  static const int _pageCount = 7;
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
    });
  }

  bool _needsLocation(ServiceRequestType t) {
    return t == ServiceRequestType.DOCTOR_HOME_VISIT ||
        t == ServiceRequestType.EMERGENCY_DOCTOR ||
        t == ServiceRequestType.AI_SERVICE;
  }

  String? _validationMessage(BookingDraft d) {
    switch (_index) {
      case 0:
        if (d.animalId == null) return 'একটি পশু নির্বাচন করুন';
      case 1:
        if (d.serviceType == null) return 'সেবার ধরন নির্বাচন করুন';
      case 2:
        if (d.problemOrSymptom.trim().isEmpty) {
          return 'সমস্যা বা লক্ষণ লিখুন';
        }
      case 4:
        final t = d.serviceType;
        if (t != null && _needsLocation(t) && d.locationText.trim().isEmpty) {
          return 'ঠিকানা বা এলাকার বর্ণনা দিন';
        }
      case 5:
        final t = d.serviceType;
        if (t == ServiceRequestType.ONLINE_CONSULTATION_LATER &&
            d.preferredTime.trim().isEmpty) {
          return 'পছন্দের সময় লিখুন';
        }
    }
    return null;
  }

  /// Full wizard validation (used before API submit on the review step).
  String? _validateAll(BookingDraft d) {
    if (d.animalId == null) return 'একটি পশু নির্বাচন করুন';
    final t = d.serviceType;
    if (t == null) return 'সেবার ধরন নির্বাচন করুন';
    if (d.problemOrSymptom.trim().isEmpty) return 'সমস্যা বা লক্ষণ লিখুন';
    if (_needsLocation(t) && d.locationText.trim().isEmpty) {
      return 'ঠিকানা বা এলাকার বর্ণনা দিন';
    }
    if (t == ServiceRequestType.ONLINE_CONSULTATION_LATER &&
        d.preferredTime.trim().isEmpty) {
      return 'পছন্দের সময় লিখুন';
    }
    return null;
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

    final body = <String, dynamic>{
      'animalId': d.animalId,
      'serviceCategoryId': categoryId,
      'serviceType': type.name,
      'problemOrSymptom': d.problemOrSymptom.trim(),
      if (d.description.trim().isNotEmpty) 'description': d.description.trim(),
      if (d.locationText.trim().isNotEmpty)
        'locationText': d.locationText.trim(),
      if (d.preferredTime.trim().isNotEmpty)
        'preferredTime': d.preferredTime.trim(),
    };

    setState(() => _submitting = true);
    try {
      final repo = ref.read(serviceRequestRepositoryProvider);
      await repo.create(body);
      if (!mounted) return;
      ref.invalidate(serviceRequestsListProvider);
      ref.read(bookingDraftProvider.notifier).reset();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('অনুরোধ জমা হয়েছে')));
      context.pop();
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
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              LinearProgressIndicator(value: (_index + 1) / _pageCount),
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 0),
                child: PraniBrandHero(
                  assetPath: PraniAssets.serviceTracking,
                  height: 128,
                  fit: BoxFit.cover,
                  semanticLabel: 'খামার সেবা অনুরোধ ট্র্যাকিং অ্যাপ চিত্রায়ণ',
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _page,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    _AnimalStep(paddingH: hPad),
                    _ServiceTypeStep(paddingH: hPad),
                    _ProblemStep(paddingH: hPad),
                    _DescriptionStep(paddingH: hPad),
                    _LocationStep(paddingH: hPad),
                    _PreferredTimeStep(paddingH: hPad),
                    _ReviewStep(
                      paddingH: hPad,
                      draft: draft,
                      submitting: _submitting,
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
        Text(
          'খামারের গবাদি প্রাণীর জন্য সেবার ধরন বেছে নিন',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        for (final t in ServiceRequestType.values) ...[
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: draft.serviceType == t
                ? scheme.primaryContainer.withValues(alpha: 0.35)
                : null,
            child: ListTile(
              title: Text(t.labelBn),
              trailing: draft.serviceType == t
                  ? Icon(Icons.check_circle, color: scheme.primary)
                  : null,
              onTap: () =>
                  ref.read(bookingDraftProvider.notifier).setServiceType(t),
            ),
          ),
        ],
      ],
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
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: ref.read(bookingDraftProvider).problemOrSymptom,
    );
  }

  @override
  void dispose() {
    _c.dispose();
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
            'সমস্যা বা লক্ষণ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'যেমন: গরু জ্বর শুনছে, ছাগল খাবার খাচ্ছে না…',
            ),
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setProblem(v),
          ),
        ],
      ),
    );
  }
}

class _DescriptionStep extends ConsumerStatefulWidget {
  const _DescriptionStep({required this.paddingH});

  final double paddingH;

  @override
  ConsumerState<_DescriptionStep> createState() => _DescriptionStepState();
}

class _DescriptionStepState extends ConsumerState<_DescriptionStep> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: ref.read(bookingDraftProvider).description,
    );
  }

  @override
  void dispose() {
    _c.dispose();
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
            'বিবরণ (ঐচ্ছিক)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'অতিরিক্ত তথ্য…',
            ),
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setDescription(v),
          ),
        ],
      ),
    );
  }
}

class _LocationStep extends ConsumerStatefulWidget {
  const _LocationStep({required this.paddingH});

  final double paddingH;

  @override
  ConsumerState<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<_LocationStep> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: ref.read(bookingDraftProvider).locationText,
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
    final required =
        type != null &&
        (type == ServiceRequestType.DOCTOR_HOME_VISIT ||
            type == ServiceRequestType.EMERGENCY_DOCTOR ||
            type == ServiceRequestType.AI_SERVICE);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(widget.paddingH, 16, widget.paddingH, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            required
                ? 'ঠিকানা / অবস্থান (প্রয়োজনীয়)'
                : 'ঠিকানা / অবস্থান (ঐচ্ছিক)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'গ্রাম, ইউনিয়ন, যোগাযোগ নম্বর বা ল্যান্ডমার্ক লিখতে পারেন।',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'বিস্তারিত ঠিকানা…',
            ),
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setLocationText(v),
          ),
        ],
      ),
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
    final required = type == ServiceRequestType.ONLINE_CONSULTATION_LATER;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(widget.paddingH, 16, widget.paddingH, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            required ? 'পছন্দের সময় (প্রয়োজনীয়)' : 'পছন্দের সময় (ঐচ্ছিক)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'উদা: আগামীকাল সকাল ১০টা',
            ),
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
    required this.onSubmit,
  });

  final double paddingH;
  final BookingDraft draft;
  final bool submitting;
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

    return ListView(
      padding: EdgeInsets.fromLTRB(paddingH, 16, paddingH, 24),
      children: [
        Text(
          'জমা দেওয়ার আগে তথ্য একবার দেখে নিন — খামারের প্রাণী ও সেবা মিলিয়ে নিন।',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        Text('যাচাই করুন', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _ReviewRow('পশু', animalName ?? '—'),
        _ReviewRow('সেবা', draft.serviceType?.labelBn ?? '—'),
        _ReviewRow(
          'সমস্যা',
          draft.problemOrSymptom.trim().isEmpty ? '—' : draft.problemOrSymptom,
        ),
        _ReviewRow(
          'বিবরণ',
          draft.description.trim().isEmpty ? '—' : draft.description,
        ),
        _ReviewRow(
          'ঠিকানা',
          draft.locationText.trim().isEmpty ? '—' : draft.locationText,
        ),
        _ReviewRow(
          'সময়',
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
