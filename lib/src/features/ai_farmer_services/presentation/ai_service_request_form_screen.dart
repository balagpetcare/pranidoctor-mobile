import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/application/ai_farmer_services_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_repository.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/presentation/ai_my_requests_screen.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class AiServiceRequestFormScreen extends ConsumerStatefulWidget {
  const AiServiceRequestFormScreen({super.key});

  static const routePath = '/ai-services/request';
  static const routeName = 'aiServiceRequestForm';

  @override
  ConsumerState<AiServiceRequestFormScreen> createState() =>
      _AiServiceRequestFormScreenState();
}

class _AiServiceRequestFormScreenState
    extends ConsumerState<AiServiceRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _breed = TextEditingController();
  final _animalAge = TextEditingController();
  final _lastHeat = TextEditingController();
  final _heatSymptoms = TextEditingController();
  final _prevAi = TextEditingController();
  final _health = TextEditingController();
  final _district = TextEditingController();
  final _upazila = TextEditingController();
  final _union = TextEditingController();
  final _address = TextEditingController();
  final _preferredTime = TextEditingController();
  final _note = TextEditingController();

  String _animalType = AiTechnicianAnimalTypes.values.first;
  bool _emergency = false;
  String? _technicianProfileId;
  String? _serviceId;
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _breed.dispose();
    _animalAge.dispose();
    _lastHeat.dispose();
    _heatSymptoms.dispose();
    _prevAi.dispose();
    _health.dispose();
    _district.dispose();
    _upazila.dispose();
    _union.dispose();
    _address.dispose();
    _preferredTime.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final q = GoRouterState.of(context).uri.queryParameters;
    _district.text = q['district'] ?? '';
    _upazila.text = q['upazila'] ?? '';
    _union.text = q['unionOrArea'] ?? '';
    _technicianProfileId = q['technicianProfileId'];
    _serviceId = q['serviceId'];
    final at = q['animalType'];
    if (at != null &&
        at.isNotEmpty &&
        AiTechnicianAnimalTypes.values.contains(at)) {
      _animalType = at;
    }
    if (q['isEmergency'] == 'true') _emergency = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'animalType': _animalType,
        'district': _district.text.trim(),
        'upazila': _upazila.text.trim(),
        'addressDetail': _address.text.trim(),
        if (_union.text.trim().isNotEmpty) 'unionOrArea': _union.text.trim(),
        if (_technicianProfileId != null && _technicianProfileId!.isNotEmpty)
          'technicianProfileId': _technicianProfileId,
        if (_serviceId != null && _serviceId!.isNotEmpty)
          'serviceId': _serviceId,
        if (_breed.text.trim().isNotEmpty) 'breed': _breed.text.trim(),
        if (_animalAge.text.trim().isNotEmpty)
          'animalAge': _animalAge.text.trim(),
        if (_lastHeat.text.trim().isNotEmpty)
          'lastHeatDate': _lastHeat.text.trim(),
        if (_heatSymptoms.text.trim().isNotEmpty)
          'heatSymptoms': _heatSymptoms.text.trim(),
        if (_prevAi.text.trim().isNotEmpty)
          'previousAiHistory': _prevAi.text.trim(),
        if (_health.text.trim().isNotEmpty)
          'healthIssueNote': _health.text.trim(),
        if (_preferredTime.text.trim().isNotEmpty)
          'preferredTime': _preferredTime.text.trim(),
        'isEmergency': _emergency,
        if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
      };
      await ref.read(aiFarmerServicesRepositoryProvider).createRequest(body);
      ref.invalidate(aiMyServiceRequestsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('অনুরোধ জমা হয়েছে')));
      context.push(AiMyServiceRequestsScreen.routePath);
    } catch (e) {
      if (!mounted) return;
      final msg = e is AiFarmerServicesApiException
          ? e.message
          : 'জমা দিতে ব্যর্থ';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);

    return PraniScaffold(
      title: 'এআই সেবার অনুরোধ',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _district,
              decoration: const InputDecoration(labelText: 'জেলা *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'জেলা লিখুন' : null,
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _upazila,
              decoration: const InputDecoration(labelText: 'উপজেলা *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'উপজেলা লিখুন' : null,
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _union,
              decoration: const InputDecoration(labelText: 'এলাকা (ঐচ্ছিক)'),
            ),
            const SizedBox(height: PraniSpacing.sm),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _animalType,
              decoration: const InputDecoration(labelText: 'প্রাণীর ধরন *'),
              items: AiTechnicianAnimalTypes.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(AiTechnicianAnimalTypes.labelBn(c)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _animalType = v);
              },
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _breed,
              decoration: const InputDecoration(labelText: 'জাত / breed'),
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _animalAge,
              decoration: const InputDecoration(labelText: 'বয়স'),
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _lastHeat,
              decoration: const InputDecoration(
                labelText: 'শেষ heat (YYYY-MM-DD বা তারিখ)',
              ),
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _heatSymptoms,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'heat লক্ষণ'),
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _prevAi,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'আগের AI history'),
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _health,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'স্বাস্থ্য সমস্যা'),
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _address,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ঠিকানা / বিস্তারিত *',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'ঠিকানা লিখুন' : null,
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _preferredTime,
              decoration: const InputDecoration(labelText: 'পছন্দের সময়'),
            ),
            const SizedBox(height: PraniSpacing.xs),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('জরুরি কি না'),
              value: _emergency,
              onChanged: (v) => setState(() => _emergency = v),
            ),
            const SizedBox(height: PraniSpacing.sm),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'অতিরিক্ত নোট'),
            ),
            const SizedBox(height: PraniSpacing.lg),
            PraniPrimaryButton(
              label: 'জমা দিন',
              isLoading: _saving,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
