// DropdownButtonFormField still uses `value` for controlled updates (Flutter deprecation noise).
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/assets/prani_assets.dart';
import 'package:pranidoctor_mobile/src/features/animals/application/animals_providers.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_model.dart';
import 'package:pranidoctor_mobile/src/features/animals/data/animal_profile_repository.dart';
import 'package:pranidoctor_mobile/src/features/animals/presentation/widgets/animal_labels.dart';

enum AnimalFormMode { create, edit }

class AnimalFormScreen extends ConsumerStatefulWidget {
  const AnimalFormScreen._({required this.mode, this.animalId});

  factory AnimalFormScreen.create() =>
      const AnimalFormScreen._(mode: AnimalFormMode.create);

  factory AnimalFormScreen.edit({required String animalId}) =>
      AnimalFormScreen._(mode: AnimalFormMode.edit, animalId: animalId);

  final AnimalFormMode mode;
  final String? animalId;

  @override
  ConsumerState<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends ConsumerState<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _tag;
  late final TextEditingController _breed;
  late final TextEditingController _notes;
  late final TextEditingController _photoUrl;
  late final TextEditingController _ageYears;

  AnimalType? _animalType;
  Gender? _gender;
  PregnancyStatus? _pregnancy;

  /// Create: false = use approximate age years; true = pick birth date.
  bool _useBirthDate = false;
  DateTime? _birthDate;

  bool _loadingExisting = false;
  String? _loadError;

  bool get _isEdit => widget.mode == AnimalFormMode.edit;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _tag = TextEditingController();
    _breed = TextEditingController();
    _notes = TextEditingController();
    _photoUrl = TextEditingController();
    _ageYears = TextEditingController();
    _animalType = AnimalType.GOAT;

    if (_isEdit) {
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  Future<void> _loadExisting() async {
    final id = widget.animalId;
    if (id == null) return;
    try {
      final a = await ref.read(animalRepositoryProvider).getById(id);
      if (!mounted) return;
      setState(() {
        _animalType = a.animalType ?? AnimalType.OTHER;
        _name.text = a.name;
        _tag.text = a.microchipOrTag ?? '';
        _breed.text = a.breed ?? '';
        _notes.text = a.notes ?? '';
        _photoUrl.text = a.photoUrl ?? '';
        _gender = a.gender;
        _pregnancy = a.pregnancyStatus;
        if (a.dateOfBirth != null) {
          _useBirthDate = true;
          _birthDate = a.dateOfBirth;
          _ageYears.clear();
        } else if (a.ageYears != null) {
          _useBirthDate = false;
          _ageYears.text = '${a.ageYears}';
          _birthDate = null;
        }
        _loadingExisting = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingExisting = false;
        _loadError = e is AnimalApiException ? e.message : 'লোড করা যায়নি';
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _tag.dispose();
    _breed.dispose();
    _notes.dispose();
    _photoUrl.dispose();
    _ageYears.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'জন্ম তারিখ',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Map<String, dynamic>? _buildCreateBody() {
    final type = _animalType;
    if (type == null) return null;

    final nameOk = _name.text.trim().isNotEmpty;
    final tagOk = _tag.text.trim().isNotEmpty;
    if (!nameOk && !tagOk) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('নাম অথবা ট্যাগ লিখুন')));
      return null;
    }

    final body = <String, dynamic>{'animalType': type.name};

    if (nameOk) body['name'] = _name.text.trim();
    if (tagOk) body['tag'] = _tag.text.trim();
    if (_breed.text.trim().isNotEmpty) body['breed'] = _breed.text.trim();

    if (_useBirthDate) {
      if (_birthDate != null) {
        body['dateOfBirth'] = _birthDate!.toUtc().toIso8601String();
      }
    } else {
      final ageText = _ageYears.text.trim();
      if (ageText.isNotEmpty) {
        final y = int.tryParse(ageText);
        if (y == null || y < 0 || y > 80) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('বয়স সঠিক সংখ্যায় লিখুন (০–৮০)')),
          );
          return null;
        }
        body['ageYears'] = y;
      }
    }

    if (_gender != null) body['gender'] = _gender!.name;
    if (_pregnancy != null) body['pregnancyStatus'] = _pregnancy!.name;
    if (_notes.text.trim().isNotEmpty) body['notes'] = _notes.text.trim();

    final pu = _photoUrl.text.trim();
    if (pu.isNotEmpty) {
      final uri = Uri.tryParse(pu);
      if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ছবির লিঙ্ক http/https দিন')),
        );
        return null;
      }
      body['photoUrl'] = pu;
    }

    return body;
  }

  Map<String, dynamic> _buildPatchBody() {
    final body = <String, dynamic>{};
    if (_animalType != null) body['animalType'] = _animalType!.name;
    body['name'] = _name.text.trim();
    body['tag'] = _tag.text.trim().isEmpty ? null : _tag.text.trim();
    body['breed'] = _breed.text.trim().isEmpty ? null : _breed.text.trim();
    body['notes'] = _notes.text.trim().isEmpty ? null : _notes.text.trim();

    final pu = _photoUrl.text.trim();
    body['photoUrl'] = pu.isEmpty ? null : pu;

    body['gender'] = _gender?.name;
    body['pregnancyStatus'] = _pregnancy?.name;

    if (_useBirthDate) {
      body['dateOfBirth'] = _birthDate?.toUtc().toIso8601String();
      body['ageYears'] = null;
    } else {
      body['dateOfBirth'] = null;
      final ageText = _ageYears.text.trim();
      if (ageText.isEmpty) {
        body['ageYears'] = null;
      } else {
        final y = int.tryParse(ageText);
        body['ageYears'] = y;
      }
    }

    return body;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(animalRepositoryProvider);

    try {
      if (!_isEdit) {
        final body = _buildCreateBody();
        if (body == null) return;
        await repo.create(body);
        if (!mounted) return;
        ref.invalidate(animalsListProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('সংরক্ষিত হয়েছে')));
        Navigator.of(context).pop();
      } else {
        final id = widget.animalId;
        if (id == null) return;
        await repo.update(id, _buildPatchBody());
        if (!mounted) return;
        ref.invalidate(animalsListProvider);
        ref.invalidate(animalDetailProvider(id));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('আপডেট হয়েছে')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AnimalApiException ? e.message : 'ব্যর্থ হয়েছে'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);

    if (_isEdit && _loadingExisting) {
      return Scaffold(
        appBar: AppBar(title: const Text('সম্পাদনা')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isEdit && _loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('সম্পাদনা')),
        body: Center(
          child: Padding(
            padding: pad,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _loadError = null;
                      _loadingExisting = true;
                    });
                    _loadExisting();
                  },
                  child: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'প্রাণি সম্পাদনা' : 'নতুন প্রাণি')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: pad.copyWith(top: 16, bottom: 32),
          children: [
            if (!_isEdit) ...[
              PraniBrandHero(
                assetPath: PraniAssets.animalEmptyState,
                height: 132,
                fit: BoxFit.contain,
                semanticLabel: 'খামারের প্রাণী যোগ করার চিত্রায়ণ',
              ),
              const SizedBox(height: 16),
              Text(
                'গরু, ছাগল, ভেড়া, হাঁস বা মুরগির তথ্য যোগ করুন',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Controlled selection — must track current state on rebuild.
            DropdownButtonFormField<AnimalType>(
              value: _animalType,
              decoration: const InputDecoration(labelText: 'প্রাণির ধরন *'),
              items: AnimalType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(animalTypeLabelBn(t)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _animalType = v),
              validator: (v) => v == null ? 'নির্বাচন করুন' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'নাম',
                hintText: 'ডাক নাম বা নাম',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tag,
              decoration: const InputDecoration(
                labelText: 'ট্যাগ / চিহ্ন',
                hintText: 'কানের ট্যাগ বা আইডি',
              ),
            ),
            if (!_isEdit)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '* নাম অথবা ট্যাগ অন্তত একটি দিন',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breed,
              decoration: const InputDecoration(labelText: 'জাত'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('জন্ম তারিখ ব্যবহার করুন'),
              subtitle: Text(
                _useBirthDate
                    ? 'ক্যালেন্ডার থেকে তারিখ বেছে নিন'
                    : 'আনুমানিক বয়স (বছর) লিখুন',
              ),
              value: _useBirthDate,
              onChanged: (v) => setState(() {
                _useBirthDate = v;
                if (v) {
                  _ageYears.clear();
                } else {
                  _birthDate = null;
                }
              }),
            ),
            if (_useBirthDate) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _birthDate == null
                      ? 'জন্ম তারিখ নির্বাচন করুন'
                      : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickBirthDate,
              ),
            ] else ...[
              TextFormField(
                controller: _ageYears,
                decoration: const InputDecoration(
                  labelText: 'বয়স (পূর্ণ বছর)',
                  hintText: 'যেমন ৩',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<Gender?>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'লিঙ্গ'),
              items: [
                const DropdownMenuItem<Gender?>(
                  value: null,
                  child: Text('নির্বাচন করুন'),
                ),
                ...Gender.values.map(
                  (g) =>
                      DropdownMenuItem(value: g, child: Text(genderLabelBn(g))),
                ),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PregnancyStatus?>(
              value: _pregnancy,
              decoration: const InputDecoration(
                labelText: 'গর্ভাবস্থা (প্রযোজ্য হলে)',
              ),
              items: [
                const DropdownMenuItem<PregnancyStatus?>(
                  value: null,
                  child: Text('নির্বাচন করুন'),
                ),
                ...PregnancyStatus.values.map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(pregnancyLabelBn(p)),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _pregnancy = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'নোট'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _photoUrl,
              decoration: const InputDecoration(
                labelText: 'ছবির লিঙ্ক (ঐচ্ছিক)',
                helperText: 'শুধু লিঙ্ক সংরক্ষণ; আপলোড পরবর্তী কাজ',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _submit,
              child: Text(_isEdit ? 'সংরক্ষণ করুন' : 'যোগ করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
