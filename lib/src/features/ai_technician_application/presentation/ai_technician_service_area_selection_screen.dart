import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_searchable_select_field.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_section_header.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/locations/application/location_providers.dart';
import 'package:pranidoctor_mobile/src/features/locations/data/location_models.dart';

/// Full-screen picker for AI technician coverage areas (district → upazila → union).
class AiTechnicianServiceAreaSelectionScreen extends ConsumerStatefulWidget {
  const AiTechnicianServiceAreaSelectionScreen({super.key, this.initialAreas});

  /// Snapshot from the wizard when pushing this route (optional).
  final List<AiTechnicianDivisionArea>? initialAreas;

  static const routePath = '/profile/ai-technician/form/service-area';
  static const routeName = 'aiTechnicianServiceAreaSelection';

  @override
  ConsumerState<AiTechnicianServiceAreaSelectionScreen> createState() =>
      _AiTechnicianServiceAreaSelectionScreenState();
}

class _AiTechnicianServiceAreaSelectionScreenState
    extends ConsumerState<AiTechnicianServiceAreaSelectionScreen> {
  bool _loadingProfile = true;
  String? _profileError;
  List<AiTechnicianDivisionArea> _areas = [];

  bool _busy = false;

  MobileLocationDto? _pickDistrict;
  MobileLocationDto? _pickUpazila;
  MobileLocationDto? _pickUnion;

  @override
  void initState() {
    super.initState();
    if (widget.initialAreas != null) {
      _areas = List<AiTechnicianDivisionArea>.from(widget.initialAreas!);
    }
    _refreshFromServer();
  }

  Future<void> _refreshFromServer() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });
    try {
      final me = await ref.read(aiTechnicianRepositoryProvider).fetchMe();
      final p = me.profile;
      if (!mounted) return;
      setState(() {
        _areas = p == null
            ? []
            : List<AiTechnicianDivisionArea>.from(p.divisionCoverageAreas);
        _loadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = e is AiTechnicianApiException
            ? e.message
            : 'প্রোফাইল লোড করা যায়নি।';
        _loadingProfile = false;
      });
    }
  }

  bool _matchesSelection(
    AiTechnicianDivisionArea a,
    MobileLocationDto d,
    MobileLocationDto u,
    MobileLocationDto? union,
  ) {
    final du = d.id.trim();
    final uu = u.id.trim();
    final nid = union?.id.trim();
    final hasUnionPick = nid != null && nid.isNotEmpty;

    final ad = a.districtId?.trim();
    final au = a.upazilaId?.trim();
    final aUni = a.unionId?.trim();

    if (ad != null && au != null && ad.isNotEmpty && au.isNotEmpty) {
      if (ad != du || au != uu) return false;
      if (!hasUnionPick) {
        return aUni == null || aUni.isEmpty;
      }
      return aUni == nid;
    }

    final unionLabel = (union?.displayLabelBn ?? '').trim();
    final existingUnion = (a.unionOrArea ?? '').trim();
    return a.district.trim() == d.displayLabelBn.trim() &&
        a.upazila.trim() == u.displayLabelBn.trim() &&
        existingUnion == unionLabel;
  }

  bool _isDuplicatePick(
    MobileLocationDto d,
    MobileLocationDto u,
    MobileLocationDto? union,
  ) {
    for (final a in _areas) {
      if (_matchesSelection(a, d, u, union)) return true;
    }
    return false;
  }

  Future<void> _addSelectedArea() async {
    final d = _pickDistrict;
    final u = _pickUpazila;
    if (d == null || u == null) {
      _toast('জেলা ও উপজেলা নির্বাচন করুন।');
      return;
    }
    if (_isDuplicatePick(d, u, _pickUnion)) {
      _toast('এই এলাকাটি ইতিমধ্যে তালিকায় আছে।');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(aiTechnicianRepositoryProvider)
          .addDivisionServiceArea(
            districtId: d.id,
            upazilaId: u.id,
            unionId: _pickUnion?.id,
            district: d.displayLabelBn,
            upazila: u.displayLabelBn,
            unionOrArea: _pickUnion?.displayLabelBn,
          );
      ref.invalidate(aiTechnicianMeProvider);
      await _refreshFromServer();
      if (mounted) {
        setState(() {
          _pickUnion = null;
        });
        _toast('সেবা এলাকা যোগ হয়েছে।');
      }
    } catch (e) {
      if (mounted) {
        _toast(e is AiTechnicianApiException ? e.message : 'যোগ করা যায়নি।');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeArea(String id) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(aiTechnicianRepositoryProvider)
          .deleteDivisionServiceArea(id);
      ref.invalidate(aiTechnicianMeProvider);
      await _refreshFromServer();
    } catch (e) {
      if (mounted) {
        _toast(e is AiTechnicianApiException ? e.message : 'মুছতে ব্যর্থ।');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(behavior: SnackBarBehavior.fixed, content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final scheme = Theme.of(context).colorScheme;

    if (_loadingProfile) {
      return PraniScaffold(
        title: 'সেবা এলাকা নির্বাচন',
        subtitle: 'জেলা, উপজেলা ও ইউনিয়ন বেছে নিন',
        body: const Center(
          child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
        ),
      );
    }

    if (_profileError != null) {
      return PraniScaffold(
        title: 'সেবা এলাকা নির্বাচন',
        body: Padding(
          padding: EdgeInsets.all(hPad),
          child: Center(
            child: PraniErrorState(
              title: 'লোড ব্যর্থ',
              message: _profileError!,
              retryLabel: 'আবার চেষ্টা',
              onRetry: _refreshFromServer,
            ),
          ),
        ),
      );
    }

    return PraniScaffold(
      title: 'সেবা এলাকা নির্বাচন',
      subtitle:
          'জেলা → উপজেলা → ইউনিয়ন (ঐচ্ছিক)। একাধিক এলাকা যোগ করতে পারবেন।',
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                PraniSpacing.md,
                hPad,
                PraniSpacing.xl,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PraniSectionHeader(
                    title: 'নতুন এলাকা যোগ করুন',
                    subtitle: 'তালিকা থেকে নির্বাচন করে যোগ করুন',
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                  PraniFormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PraniSearchableSelectField<MobileLocationDto>(
                          label: 'জেলা *',
                          hintEmpty: 'জেলা নির্বাচন করুন',
                          enabled: !_busy,
                          selectedItem: _pickDistrict,
                          sheetTitle: 'জেলা খুঁজুন',
                          displayBuilder: (x) => x.displayLabelBn,
                          loadItems: () => ref
                              .read(locationRepositoryProvider)
                              .fetchDistricts(),
                          onChanged: (v) => setState(() {
                            _pickDistrict = v;
                            _pickUpazila = null;
                            _pickUnion = null;
                          }),
                        ),
                        const SizedBox(height: PraniSpacing.md),
                        PraniSearchableSelectField<MobileLocationDto>(
                          label: 'উপজেলা *',
                          hintEmpty: _pickDistrict == null
                              ? 'প্রথমে জেলা নির্বাচন করুন'
                              : 'উপজেলা নির্বাচন করুন',
                          enabled: !_busy && _pickDistrict != null,
                          selectedItem: _pickUpazila,
                          sheetTitle: 'উপজেলা খুঁজুন',
                          displayBuilder: (x) => x.displayLabelBn,
                          loadItems: () {
                            final id = _pickDistrict?.id;
                            if (id == null) {
                              return Future.value(const <MobileLocationDto>[]);
                            }
                            return ref
                                .read(locationRepositoryProvider)
                                .fetchUpazilas(districtId: id);
                          },
                          onChanged: (v) => setState(() {
                            _pickUpazila = v;
                            _pickUnion = null;
                          }),
                        ),
                        const SizedBox(height: PraniSpacing.md),
                        PraniSearchableSelectField<MobileLocationDto>(
                          label: 'ইউনিয়ন / এলাকা (ঐচ্ছিক)',
                          hintEmpty: _pickUpazila == null
                              ? 'প্রথমে উপজেলা নির্বাচন করুন'
                              : 'ইউনিয়ন নির্বাচন করুন',
                          enabled:
                              !_busy &&
                              _pickDistrict != null &&
                              _pickUpazila != null,
                          selectedItem: _pickUnion,
                          sheetTitle: 'ইউনিয়ন খুঁজুন',
                          displayBuilder: (x) => x.displayLabelBn,
                          loadItems: () {
                            final dId = _pickDistrict?.id;
                            final uId = _pickUpazila?.id;
                            if (dId == null || uId == null) {
                              return Future.value(const <MobileLocationDto>[]);
                            }
                            return ref
                                .read(locationRepositoryProvider)
                                .fetchUnions(districtId: dId, upazilaId: uId);
                          },
                          onChanged: (v) => setState(() => _pickUnion = v),
                        ),
                        const SizedBox(height: PraniSpacing.lg),
                        PraniPrimaryButton(
                          label: 'এই এলাকা যোগ করুন',
                          isLoading: _busy,
                          onPressed: _busy ? null : _addSelectedArea,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.xl),
                  Text(
                    'নির্বাচিত সেবা এলাকাসমূহ (${_areas.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.sm),
                  if (_areas.isEmpty)
                    PraniFormCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: PraniSpacing.lg,
                        ),
                        child: Text(
                          'এখনো কোনো সেবা এলাকা যোগ করা হয়নি',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    PraniFormCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < _areas.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${_areas[i].district} / ${_areas[i].upazila}',
                              ),
                              subtitle:
                                  (_areas[i].unionOrArea ?? '').trim().isEmpty
                                  ? null
                                  : Text(_areas[i].unionOrArea!),
                              trailing: IconButton(
                                tooltip: 'সরান',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: _busy
                                    ? null
                                    : () => _removeArea(_areas[i].id),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Material(
            color: scheme.surface,
            elevation: 2,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 12),
                child: PraniPrimaryButton(
                  label: 'নির্বাচন সম্পন্ন',
                  onPressed: _busy
                      ? null
                      : () {
                          context.pop(true);
                        },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
