import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_app_header.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_searchable_select_field.dart';
import 'package:pranidoctor_mobile/src/features/locations/application/guest_location_preference.dart';
import 'package:pranidoctor_mobile/src/features/locations/application/location_providers.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_models.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_repository.dart';

/// Opens bottom sheet to choose district → upazila → union (API-backed IDs).
Future<void> showGuestLocationSelectionSheet(
  BuildContext context, {
  bool showSkip = true,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: scheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(PraniRadius.lg)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Consumer(
          builder: (context, r, _) {
            return _GuestLocationSheetBody(
              showSkip: showSkip,
              onSaved: () => Navigator.of(context).pop(),
              onSkipped: () => Navigator.of(context).pop(),
            );
          },
        ),
      );
    },
  );
}

class _GuestLocationSheetBody extends ConsumerStatefulWidget {
  const _GuestLocationSheetBody({
    required this.showSkip,
    required this.onSaved,
    required this.onSkipped,
  });

  final bool showSkip;
  final VoidCallback onSaved;
  final VoidCallback onSkipped;

  @override
  ConsumerState<_GuestLocationSheetBody> createState() =>
      _GuestLocationSheetBodyState();
}

class _GuestLocationSheetBodyState
    extends ConsumerState<_GuestLocationSheetBody> {
  MobileLocationDto? _district;
  MobileLocationDto? _upazila;
  MobileLocationDto? _union;
  bool _saving = false;

  /// One-shot: hydrate saved guest IDs or auto-select sole district.
  bool _selectionBootstrapDone = false;

  LocationRepository get _repo => ref.read(locationRepositoryProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapSelection());
  }

  /// Prefers saved guest union chain; otherwise auto-picks when only one district exists.
  Future<void> _bootstrapSelection() async {
    if (_selectionBootstrapDone || !mounted) return;
    try {
      final guest = await ref.read(guestLocationPreferenceProvider.future);
      final districts = await ref.read(districtsProvider.future);

      if (!mounted) return;

      if (guest.hasSavedSelection) {
        MobileLocationDto? dSel;
        for (final d in districts) {
          if (d.id == guest.districtId) {
            dSel = d;
            break;
          }
        }
        if (dSel == null) {
          return;
        }

        final upazilas = await _repo.fetchUpazilas(districtId: dSel.id);
        if (!mounted) return;

        MobileLocationDto? zSel;
        for (final z in upazilas) {
          if (z.id == guest.upazilaId) {
            zSel = z;
            break;
          }
        }

        MobileLocationDto? uSel;
        if (zSel != null) {
          final unions = await _repo.fetchUnions(
            districtId: dSel.id,
            upazilaId: zSel.id,
          );
          if (!mounted) return;
          final uid = guest.unionId;
          if (uid != null) {
            for (final u in unions) {
              if (u.id == uid) {
                uSel = u;
                break;
              }
            }
          }
        }

        if (!mounted) return;
        setState(() {
          _district = dSel;
          _upazila = zSel;
          _union = uSel;
        });
        return;
      }

      if (districts.length == 1) {
        setState(() {
          _district = districts.first;
          _upazila = null;
          _union = null;
        });
      }
    } catch (e, st) {
      assert(() {
        debugPrint('Guest location bootstrap: $e\n$st');
        return true;
      }());
    } finally {
      _selectionBootstrapDone = true;
    }
  }

  Future<List<MobileLocationDto>> _loadUpazilas() async {
    final d = _district;
    if (d == null) return [];
    return _repo.fetchUpazilas(districtId: d.id);
  }

  Future<List<MobileLocationDto>> _loadUnions() async {
    final d = _district;
    final u = _upazila;
    if (d == null || u == null) return [];
    return _repo.fetchUnions(districtId: d.id, upazilaId: u.id);
  }

  Future<void> _save() async {
    final d = _district;
    final z = _upazila;
    final n = _union;
    if (d == null || z == null || n == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('উপজেলা ও ইউনিয়ন নির্বাচন করুন।'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(guestLocationPreferenceProvider.notifier)
          .saveSelection(
            districtId: d.id,
            upazilaId: z.id,
            unionId: n.id,
            districtLabelBn: d.displayLabelBn,
            upazilaLabelBn: z.displayLabelBn,
            unionLabelBn: n.displayLabelBn,
          );
      if (!mounted) return;
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('সংরক্ষণ ব্যর্থ। আবার চেষ্টা করুন।'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _skip() async {
    await ref
        .read(guestLocationPreferenceProvider.notifier)
        .dismissPromptWithoutSaving();
    if (!mounted) return;
    widget.onSkipped();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    final needsDistrictPick = ref
        .watch(districtsProvider)
        .maybeWhen(data: (list) => list.length > 1, orElse: () => false);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PraniSpacing.xl,
                PraniSpacing.sm,
                PraniSpacing.xl,
                PraniSpacing.xs,
              ),
              child: PraniAppHeader(
                title: 'আপনার এলাকা নির্বাচন করুন',
                subtitle:
                    'আপনার এলাকার ডাক্তার, টেকনিশিয়ান ও সেবা দেখতে উপজেলা ও ইউনিয়ন নির্বাচন করুন।',
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(PraniSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ref
                        .watch(districtsProvider)
                        .when(
                          data: (districts) {
                            if (districts.isEmpty) {
                              return Text(
                                'জেলার তালিকা খালি। পরে আবার চেষ্টা করুন।',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.error,
                                ),
                              );
                            }
                            if (districts.length > 1) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'একাধিক জেলা থাকলে প্রথমে জেলা বেছে নিন।',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: PraniSpacing.lg),
                                  PraniSearchableSelectField<MobileLocationDto>(
                                    label: 'জেলা',
                                    hintEmpty: 'জেলা নির্বাচন করুন',
                                    enabled: true,
                                    selectedItem: _district,
                                    displayBuilder: (e) => e.displayLabelBn,
                                    sheetTitle: 'জেলা খুঁজুন',
                                    loadItems: () async => districts,
                                    onChanged: (v) {
                                      setState(() {
                                        _district = v;
                                        _upazila = null;
                                        _union = null;
                                      });
                                    },
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: PraniLoadingState(
                                message: 'জেলা লোড হচ্ছে…',
                                compact: false,
                              ),
                            ),
                          ),
                          error: (_, _) => PraniErrorState(
                            title: 'লোকেশন লোড করা যায়নি',
                            message: 'লোকেশন লোড করা যায়নি। আবার চেষ্টা করুন।',
                            retryLabel: 'আবার চেষ্টা করুন',
                            onRetry: () => ref.invalidate(districtsProvider),
                            detail: null,
                            compact: false,
                            boxed: true,
                          ),
                        ),
                    const SizedBox(height: PraniSpacing.md),
                    PraniSearchableSelectField<MobileLocationDto>(
                      label: 'উপজেলা',
                      hintEmpty: _district == null
                          ? (needsDistrictPick
                                ? 'আগে জেলা নির্বাচন করুন'
                                : 'জেলা লোড হচ্ছে…')
                          : 'উপজেলা নির্বাচন করুন',
                      enabled: _district != null,
                      selectedItem: _upazila,
                      displayBuilder: (e) => e.displayLabelBn,
                      sheetTitle: 'উপজেলা খুঁজুন',
                      loadItems: _loadUpazilas,
                      emptyListMessage: 'এই জেলার উপজেলা পাওয়া যায়নি',
                      onChanged: (v) {
                        setState(() {
                          _upazila = v;
                          _union = null;
                        });
                      },
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    PraniSearchableSelectField<MobileLocationDto>(
                      label: 'ইউনিয়ন',
                      hintEmpty: _upazila == null
                          ? 'আগে উপজেলা নির্বাচন করুন'
                          : 'ইউনিয়ন নির্বাচন করুন',
                      enabled: _upazila != null,
                      selectedItem: _union,
                      displayBuilder: (e) => e.displayLabelBn,
                      sheetTitle: 'ইউনিয়ন খুঁজুন',
                      loadItems: _loadUnions,
                      emptyListMessage: 'এই উপজেলার ইউনিয়ন পাওয়া যায়নি',
                      onChanged: (v) => setState(() => _union = v),
                    ),
                    const SizedBox(height: PraniSpacing.xl),
                    PraniPrimaryButton(
                      label: 'সেভ করুন',
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                    if (widget.showSkip) ...[
                      const SizedBox(height: PraniSpacing.sm),
                      PraniSecondaryButton(
                        label: 'এখন নয়',
                        fullWidth: true,
                        onPressed: _saving ? null : _skip,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
