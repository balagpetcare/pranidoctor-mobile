import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_empty_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_provider_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/application/ai_farmer_services_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_repository.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_technician_public_profile_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_service_request_form_screen.dart';

class AiTechnicianFinderScreen extends ConsumerStatefulWidget {
  const AiTechnicianFinderScreen({super.key});

  static const routePath = '/ai-services/technicians';
  static const routeName = 'aiTechnicianFinder';

  @override
  ConsumerState<AiTechnicianFinderScreen> createState() =>
      _AiTechnicianFinderScreenState();
}

class _AiTechnicianFinderScreenState
    extends ConsumerState<AiTechnicianFinderScreen> {
  final _district = TextEditingController();
  final _upazila = TextEditingController();
  final _union = TextEditingController();
  String _animalType = '';
  bool _emergency = false;

  bool _loading = false;
  String? _error;
  List<AiTechnicianForServiceSummary> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _district.dispose();
    _upazila.dispose();
    _union.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final d = _district.text.trim();
    final u = _upazila.text.trim();
    if (d.isEmpty || u.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('জেলা ও উপজেলা লিখুন')));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _hasSearched = true;
    });
    try {
      final repo = ref.read(aiFarmerServicesRepositoryProvider);
      final out = await repo.listTechniciansForAiService(
        district: d,
        upazila: u,
        unionOrArea: _union.text.trim().isEmpty ? null : _union.text.trim(),
        animalType: _animalType.isEmpty ? null : _animalType,
        emergency: _emergency ? true : null,
      );
      if (!mounted) return;
      setState(() {
        _results = out.technicians;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e is AiFarmerServicesApiException
          ? e.message
          : 'খুঁজতে ব্যর্থ হয়েছে';
      setState(() {
        _error = msg;
        _results = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final scheme = Theme.of(context).colorScheme;

    return PraniScaffold(
      title: 'এআই টেকনিশিয়ান খুঁজুন',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _district,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'জেলা',
              hintText: 'যেমন: ঢাকা',
            ),
          ),
          const SizedBox(height: PraniSpacing.sm),
          TextField(
            controller: _upazila,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'উপজেলা'),
          ),
          const SizedBox(height: PraniSpacing.sm),
          TextField(
            controller: _union,
            decoration: const InputDecoration(labelText: 'এলাকা (ঐচ্ছিক)'),
          ),
          const SizedBox(height: PraniSpacing.sm),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _animalType.isEmpty ? '' : _animalType,
            decoration: const InputDecoration(
              labelText: 'প্রাণীর ধরন (ঐচ্ছিক)',
            ),
            items: [
              const DropdownMenuItem<String>(value: '', child: Text('সব ধরন')),
              ...AiTechnicianAnimalTypes.values.map(
                (c) => DropdownMenuItem<String>(
                  value: c,
                  child: Text(AiTechnicianAnimalTypes.labelBn(c)),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _animalType = v ?? ''),
          ),
          const SizedBox(height: PraniSpacing.xs),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('জরুরি সেবা'),
            value: _emergency,
            onChanged: (v) => setState(() => _emergency = v),
          ),
          const SizedBox(height: PraniSpacing.md),
          PraniPrimaryButton(
            label: 'খুঁজুন',
            isLoading: _loading,
            onPressed: _loading ? null : _search,
          ),
          const SizedBox(height: PraniSpacing.lg),
          Expanded(child: _buildResults(context, scheme)),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, ColorScheme scheme) {
    if (_loading && !_hasSearched) {
      return const SizedBox.shrink();
    }
    if (_loading) {
      return const Center(
        child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          PraniEmptyState(
            title: 'ত্রুটি',
            message: _error!,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: PraniSpacing.md),
          PraniSecondaryButton(label: 'আবার চেষ্টা', onPressed: _search),
        ],
      );
    }
    if (!_hasSearched) {
      return PraniEmptyState(
        title: 'ফিল্টার দিন',
        message: 'জেলা ও উপজেলা লিখে খুঁজুন চাপুন।',
        icon: Icons.filter_alt_outlined,
      );
    }
    if (_results.isEmpty) {
      return PraniEmptyState(
        title: 'কেউ পাওয়া যায়নি',
        message: 'আপনার এলাকায় কোনো এআই টেকনিশিয়ান পাওয়া যায়নি',
        icon: Icons.search_off_outlined,
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _results.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: PraniSpacing.sm),
      itemBuilder: (context, i) {
        final t = _results[i];
        final fee = t.startingPriceBdt != null ? '৳${t.startingPriceBdt}' : '—';
        final types = t.serviceTitles.isEmpty
            ? 'কৃত্রিম প্রজনন'
            : t.serviceTitles.take(3).join(' · ');
        return PraniProviderCard(
          name: t.displayName,
          roleLine: t.verified ? 'যাচাইকৃত' : null,
          areaLine: t.serviceAreaSummary,
          feeLine: 'শুরুর মূল্য: $fee',
          tags: [
            if (t.acceptsEmergency)
              Chip(
                label: const Text('জরুরি'),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: scheme.onSecondaryContainer,
                ),
                backgroundColor: scheme.secondaryContainer,
              ),
          ],
          availabilityLine: types,
          ratingLine: t.ratingCount > 0
              ? 'রেটিং ${t.ratingAverage?.toStringAsFixed(1) ?? '—'} (${t.ratingCount})'
              : 'রেটিং শীঘ্রই',
          onTap: () => context.push(
            '${AiTechnicianPublicProfileScreen.routePath}/${t.id}',
          ),
          primaryActionLabel: 'অনুরোধ',
          onPrimaryAction: () {
            final q = Uri(
              queryParameters: <String, String>{
                'district': _district.text.trim(),
                'upazila': _upazila.text.trim(),
                if (_union.text.trim().isNotEmpty)
                  'unionOrArea': _union.text.trim(),
                'technicianProfileId': t.id,
                if (_animalType.isNotEmpty) 'animalType': _animalType,
              },
            );
            context.push('${AiServiceRequestFormScreen.routePath}$q');
          },
        );
      },
    );
  }
}
