import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/core/network/mobile_api_envelope.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_design_system.dart';
import 'package:pranidoctor_mobile/src/features/locations/application/location_providers.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/bangla_input_validation.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_models.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_profile_api_contract.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

/// Division → village; persists via [MobileUserRepository.updateLocation].
class EditProfileLocationScreen extends ConsumerStatefulWidget {
  const EditProfileLocationScreen({super.key});

  static const routePath = '/profile/edit/location';
  static const routeName = 'profileEditLocation';

  @override
  ConsumerState<EditProfileLocationScreen> createState() =>
      _EditProfileLocationScreenState();
}

class _EditProfileLocationScreenState
    extends ConsumerState<EditProfileLocationScreen> {
  final _villageCustom = TextEditingController();

  MobileLocationDto? _division;
  MobileLocationDto? _district;
  MobileLocationDto? _upazila;
  MobileLocationDto? _union;
  MobileLocationDto? _village;

  String _initialArea = '';
  MobileUser? _loadedUser;
  bool _loadingUser = true;
  bool _hydrating = false;
  String? _loadError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUser());
  }

  @override
  void dispose() {
    _villageCustom.dispose();
    super.dispose();
  }

  bool _hasSavedLocationOnProfile(MobileUser user) {
    if (user.isLocationConfigured) return true;
    return MobileUser.areaLooksLikeRealUserLocation(user.area);
  }

  String _normalizeArea(String? raw) {
    final t = raw?.trim() ?? '';
    if (t.isEmpty ||
        t == MobileUser.kPlaceholderAreaBn ||
        t == 'এলাকা সেট করা হয়নি') {
      return '';
    }
    return t;
  }

  Future<void> _loadUser() async {
    try {
      final user = await ref.read(mobileUserProvider.future);
      if (!mounted) return;
      _loadedUser = user;
      final norm = _normalizeArea(user.area);
      setState(() {
        _initialArea = norm;
        _loadingUser = false;
        _loadError = null;
      });
      await _hydrateCascadeFromUser(user);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingUser = false;
        _loadError = e is ProfileApiException
            ? e.message
            : 'ডেটা লোড করা যায়নি।';
      });
    }
  }

  Future<void> _hydrateCascadeFromUser(MobileUser user) async {
    final divId = user.divisionId?.trim();
    if (divId == null || divId.isEmpty) return;

    if (!mounted) return;
    setState(() => _hydrating = true);
    try {
      final repo = ref.read(locationRepositoryProvider);
      final divisions = await ref.read(divisionsProvider.future);
      MobileLocationDto? div;
      for (final e in divisions) {
        if (e.id == divId) {
          div = e;
          break;
        }
      }
      if (div == null) return;

      final distId = user.districtId?.trim();
      if (distId == null || distId.isEmpty) {
        if (mounted) setState(() => _division = div);
        return;
      }
      final districts = await repo.fetchDistricts(divisionId: div.id);
      MobileLocationDto? dist;
      for (final e in districts) {
        if (e.id == distId) {
          dist = e;
          break;
        }
      }
      if (dist == null) {
        if (mounted) setState(() => _division = div);
        return;
      }

      final upId = user.upazilaId?.trim();
      if (upId == null || upId.isEmpty) {
        if (mounted) {
          setState(() {
            _division = div;
            _district = dist;
          });
        }
        return;
      }
      final upazilas = await repo.fetchUpazilas(districtId: dist.id);
      MobileLocationDto? up;
      for (final e in upazilas) {
        if (e.id == upId) {
          up = e;
          break;
        }
      }
      if (up == null) {
        if (mounted) {
          setState(() {
            _division = div;
            _district = dist;
          });
        }
        return;
      }

      final unId = user.unionId?.trim();
      if (unId == null || unId.isEmpty) {
        if (mounted) {
          setState(() {
            _division = div;
            _district = dist;
            _upazila = up;
          });
        }
        return;
      }
      final unions = await repo.fetchUnions(
        districtId: dist.id,
        upazilaId: up.id,
      );
      MobileLocationDto? un;
      for (final e in unions) {
        if (e.id == unId) {
          un = e;
          break;
        }
      }
      if (un == null) {
        if (mounted) {
          setState(() {
            _division = div;
            _district = dist;
            _upazila = up;
          });
        }
        return;
      }

      final vilId = user.villageId?.trim();
      final villages = await repo.fetchVillages(unionId: un.id);
      MobileLocationDto? vil;
      if (vilId != null && vilId.isNotEmpty) {
        for (final e in villages) {
          if (e.id == vilId) {
            vil = e;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _division = div;
        _district = dist;
        _upazila = up;
        _union = un;
        _village = vil;
      });

      if (vil == null) {
        final vn = user.villageName?.trim();
        if (vn != null && vn.isNotEmpty) {
          _villageCustom.text = vn;
        }
      }
    } catch (e, st) {
      assert(() {
        debugPrint('EditProfileLocationScreen hydrate: $e\n$st');
        return true;
      }());
    } finally {
      if (mounted) setState(() => _hydrating = false);
    }
  }

  bool get _hasNewCustomVillage {
    final t = _villageCustom.text.trim();
    if (t.isEmpty) return false;
    if (_village == null) return true;
    return _village!.displayLabelBn.trim() != t;
  }

  /// Valid end state: picked from list, or Bangla-only custom name (no list pick).
  bool get _villageStepValid {
    if (_village != null) {
      if (!_hasNewCustomVillage) return true;
      return validateOptionalBnVillageName(_villageCustom.text) == null;
    }
    return validateOptionalBnVillageName(_villageCustom.text) == null &&
        _villageCustom.text.trim().length >= 2;
  }

  String? get _villageFieldError {
    final t = _villageCustom.text.trim();
    if (t.isEmpty) return null;
    return validateOptionalBnVillageName(t);
  }

  bool get _canSave {
    if (_saving || _hydrating || _loadingUser) return false;
    if (_district == null || _upazila == null || _union == null) return false;
    if (_division == null) return false;
    if (!_villageStepValid) return false;
    return true;
  }

  String _composeAreaLabel() {
    final parts = <String>[];
    if (_division != null) parts.add(_division!.displayLabelBn);
    if (_district != null) parts.add(_district!.displayLabelBn);
    if (_upazila != null) parts.add(_upazila!.displayLabelBn);
    if (_union != null) parts.add(_union!.displayLabelBn);
    if (_village != null && !_hasNewCustomVillage) {
      parts.add(_village!.displayLabelBn);
    }
    final custom = _villageCustom.text.trim();
    if (custom.isNotEmpty) parts.add(custom);
    return parts.join(', ');
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final composed = _composeAreaLabel().trim();
    if (composed.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('সম্পূর্ণ ঠিকানা তৈরি হয়নি।'),
        ),
      );
      return;
    }
    if (composed == _initialArea.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('কোনো পরিবর্তন নেই।')));
      return;
    }
    await _persist(composed);
  }

  Future<void> _persist(String composed) async {
    setState(() => _saving = true);
    var villageId = _village?.id;
    final unionId = _union!.id;
    final custom = _villageCustom.text.trim();

    try {
      if (_hasNewCustomVillage && custom.isNotEmpty) {
        try {
          final created = await ref
              .read(locationRepositoryProvider)
              .createVillage(unionId: unionId, nameBn: custom);
          villageId = created.id;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('নতুন গ্রাম সার্ভারে নিবন্ধিত হয়েছে।'),
              ),
            );
          }
        } on MobileApiEnvelopeException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(e.message),
              ),
            );
          }
          villageId = null;
        }
      }

      String? villageNameOut;
      if (_village != null && !_hasNewCustomVillage) {
        villageNameOut = _village!.displayLabelBn;
      } else if (custom.isNotEmpty) {
        villageNameOut = custom;
      }

      await ref
          .read(profileRepositoryProvider)
          .updateLocation(
            MobileUserLocationUpdate(
              area: composed,
              divisionId: _division?.id,
              districtId: _district?.id,
              upazilaId: _upazila?.id,
              unionId: _union?.id,
              villageId: villageId,
              villageName: villageNameOut,
            ),
          );
      ref.invalidate(mobileUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('ঠিকানা সংরক্ষিত হয়েছে।'),
        ),
      );
      context.pop();
    } on ProfileApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সংরক্ষণ ব্যর্থ। আবার চেষ্টা করুন।')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _districtsFamilyKey() => _division?.id ?? '';

  bool _autoDivisionApplied = false;

  void _maybeAutoSelectDivision(List<MobileLocationDto> divisions) {
    if (_autoDivisionApplied || !mounted || divisions.isEmpty) return;
    if (divisions.length == 1 && _division == null) {
      _autoDivisionApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _division = divisions.first;
          _district = null;
          _upazila = null;
          _union = null;
          _village = null;
          _villageCustom.clear();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final divisionsAsync = ref.watch(divisionsProvider);
    final districtsAsync = ref.watch(
      districtsForDivisionProvider(_districtsFamilyKey()),
    );

    final user = _loadedUser;
    final hasSaved = user != null && _hasSavedLocationOnProfile(user);

    return PraniScaffold(
      title: 'ঠিকানা / লোকেশন',
      subtitle: 'বিভাগ থেকে গ্রাম — ধাপে ধাপে নির্বাচন করুন',
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: pad,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: PraniSpacing.xl),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loadingUser = true;
                          _loadError = null;
                        });
                        _loadUser();
                      },
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: pad.copyWith(top: PraniSpacing.md, bottom: 32),
              children: [
                if (_hydrating)
                  const Padding(
                    padding: EdgeInsets.only(bottom: PraniSpacing.md),
                    child: PraniLoadingState(
                      message: 'সংরক্ষিত ঠিকানা লোড হচ্ছে…',
                      compact: true,
                    ),
                  ),
                if (!hasSaved) ...[
                  Icon(
                    Icons.location_off_outlined,
                    size: 48,
                    color: scheme.outline,
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  Text(
                    'কোনো ঠিকানা সংরক্ষিত নেই',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                  Text(
                    'সেবা পেতে নিচে বিভাগ থেকে শুরু করে আপনার গ্রাম পর্যন্ত নির্বাচন করুন।',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                ] else if (_initialArea.isNotEmpty) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(PraniRadii.md),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(PraniSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'বর্তমান সংরক্ষিত ঠিকানা',
                            style: textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.xs),
                          Text(
                            _initialArea,
                            style: textTheme.bodyLarge?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                ],
                Text(
                  'প্রতিটি ধাপ পূরণ করুন। গ্রাম তালিকায় খুঁজুন বা বাংলায় নতুন নাম লিখুন।',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: PraniSpacing.lg),
                divisionsAsync.when(
                  data: (divisions) {
                    _maybeAutoSelectDivision(divisions);
                    if (divisions.isEmpty) {
                      return Text(
                        'বিভাগের তালিকা খালি। পরে আবার চেষ্টা করুন।',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.error,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PraniSearchableSelectField<MobileLocationDto>(
                          label: 'বিভাগ',
                          hintEmpty: 'বিভাগ নির্বাচন করুন',
                          enabled: !_hydrating,
                          selectedItem: _division,
                          displayBuilder: (e) => e.displayLabelBn,
                          sheetTitle: 'বিভাগ খুঁজুন',
                          loadItems: () async => divisions,
                          onChanged: (v) {
                            setState(() {
                              _division = v;
                              _district = null;
                              _upazila = null;
                              _union = null;
                              _village = null;
                              _villageCustom.clear();
                            });
                          },
                        ),
                        const SizedBox(height: PraniSpacing.md),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.only(bottom: PraniSpacing.md),
                    child: PraniLoadingState(
                      message: 'বিভাগ লোড হচ্ছে…',
                      compact: true,
                    ),
                  ),
                  error: (err, st) => Padding(
                    padding: const EdgeInsets.only(bottom: PraniSpacing.md),
                    child: PraniErrorState(
                      title: 'বিভাগ লোড হয়নি',
                      message: 'নেটওয়ার্ক বা সার্ভার পরীক্ষা করুন।',
                      retryLabel: 'আবার চেষ্টা',
                      onRetry: () => ref.invalidate(divisionsProvider),
                      detail: null,
                      compact: true,
                      boxed: true,
                    ),
                  ),
                ),
                districtsAsync.when(
                  data: (districts) {
                    if (_division == null) {
                      return Text(
                        'প্রথমে বিভাগ নির্বাচন করুন।',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      );
                    }
                    if (districts.isEmpty) {
                      return Text(
                        'এই বিভাগে জেলা পাওয়া যায়নি।',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.error,
                        ),
                      );
                    }
                    return PraniSearchableSelectField<MobileLocationDto>(
                      label: 'জেলা',
                      hintEmpty: 'জেলা নির্বাচন করুন',
                      enabled: _division != null && !_hydrating,
                      selectedItem: _district,
                      displayBuilder: (e) => e.displayLabelBn,
                      sheetTitle: 'জেলা খুঁজুন',
                      loadItems: () async => districts,
                      onChanged: (v) {
                        setState(() {
                          _district = v;
                          _upazila = null;
                          _union = null;
                          _village = null;
                          _villageCustom.clear();
                        });
                      },
                    );
                  },
                  loading: () => _division != null
                      ? const PraniLoadingState(
                          message: 'জেলা লোড হচ্ছে…',
                          compact: true,
                        )
                      : const SizedBox.shrink(),
                  error: (err, st) => _division != null
                      ? PraniErrorState(
                          title: 'জেলা লোড হয়নি',
                          message: 'নেটওয়ার্ক বা সার্ভার পরীক্ষা করুন।',
                          retryLabel: 'আবার চেষ্টা',
                          onRetry: () => ref.invalidate(
                            districtsForDivisionProvider(_districtsFamilyKey()),
                          ),
                          detail: null,
                          compact: true,
                          boxed: true,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: PraniSpacing.md),
                PraniSearchableSelectField<MobileLocationDto>(
                  label: 'উপজেলা',
                  hintEmpty: 'উপজেলা নির্বাচন করুন',
                  enabled: _district != null && !_hydrating,
                  selectedItem: _upazila,
                  displayBuilder: (e) => e.displayLabelBn,
                  sheetTitle: 'উপজেলা খুঁজুন',
                  loadItems: () async {
                    final d = _district;
                    if (d == null) return [];
                    return ref
                        .read(locationRepositoryProvider)
                        .fetchUpazilas(districtId: d.id);
                  },
                  onChanged: (v) {
                    setState(() {
                      _upazila = v;
                      _union = null;
                      _village = null;
                      _villageCustom.clear();
                    });
                  },
                ),
                const SizedBox(height: PraniSpacing.md),
                PraniSearchableSelectField<MobileLocationDto>(
                  label: 'ইউনিয়ন',
                  hintEmpty: 'ইউনিয়ন নির্বাচন করুন',
                  enabled: _district != null && _upazila != null && !_hydrating,
                  selectedItem: _union,
                  displayBuilder: (e) => e.displayLabelBn,
                  sheetTitle: 'ইউনিয়ন খুঁজুন',
                  loadItems: () async {
                    final d = _district;
                    final z = _upazila;
                    if (d == null || z == null) return [];
                    return ref
                        .read(locationRepositoryProvider)
                        .fetchUnions(districtId: d.id, upazilaId: z.id);
                  },
                  onChanged: (v) {
                    setState(() {
                      _union = v;
                      _village = null;
                      _villageCustom.clear();
                    });
                  },
                ),
                const SizedBox(height: PraniSpacing.md),
                PraniSearchableSelectField<MobileLocationDto>(
                  label: 'গ্রাম',
                  hintEmpty: 'তালিকা থেকে গ্রাম খুঁজে বেছে নিন',
                  enabled: _union != null && !_hydrating,
                  selectedItem: _village,
                  displayBuilder: (e) => e.displayLabelBn,
                  sheetTitle: 'গ্রাম খুঁজুন',
                  emptyListMessage:
                      'এই ইউনিয়নে গ্রাম পাওয়া যায়নি। নিচে বাংলায় নাম লিখুন।',
                  loadItems: () async {
                    final u = _union;
                    if (u == null) return [];
                    return ref
                        .read(locationRepositoryProvider)
                        .fetchVillages(unionId: u.id);
                  },
                  onChanged: (v) {
                    setState(() {
                      _village = v;
                      _villageCustom.clear();
                    });
                  },
                ),
                const SizedBox(height: PraniSpacing.md),
                TextFormField(
                  controller: _villageCustom,
                  decoration: InputDecoration(
                    labelText: 'গ্রামের নাম (তালিকায় না থাকলে)',
                    hintText: 'শুধু বাংলায় লিখুন',
                    alignLabelWithHint: true,
                    errorText: _villageFieldError,
                  ),
                  onChanged: (t) {
                    setState(() {
                      final sel = _village?.displayLabelBn.trim();
                      final tr = t.trim();
                      if (tr.isNotEmpty && (sel == null || sel != tr)) {
                        _village = null;
                      }
                    });
                  },
                ),
                if (_hasNewCustomVillage &&
                    validateOptionalBnVillageName(_villageCustom.text) ==
                        null) ...[
                  const SizedBox(height: PraniSpacing.sm),
                  Text(
                    'এই গ্রামের নামটি নতুন হিসেবে সংরক্ষণ হবে',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: PraniSpacing.section),
                FilledButton(
                  onPressed: !_canSave || _saving
                      ? null
                      : () async {
                          await _save();
                        },
                  child: _saving
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : const Text('ঠিকানা সংরক্ষণ করুন'),
                ),
              ],
            ),
    );
  }
}
