import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_fields.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_services_list_screen.dart';

class AiTechnicianServiceFormScreen extends ConsumerStatefulWidget {
  const AiTechnicianServiceFormScreen({super.key, this.serviceId});

  /// `null` = create new service.
  final String? serviceId;

  static const routeNameNew = 'aiTechnicianServiceNew';
  static const routeNameEdit = 'aiTechnicianServiceEdit';

  @override
  ConsumerState<AiTechnicianServiceFormScreen> createState() =>
      _AiTechnicianServiceFormScreenState();
}

class _AiTechnicianServiceFormScreenState
    extends ConsumerState<AiTechnicianServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _breed;
  late final TextEditingController _description;
  late final TextEditingController _basePrice;
  late final TextEditingController _visitFee;
  late final TextEditingController _emergencyFee;
  late final TextEditingController _repeatPolicy;
  late final TextEditingController _offerPrice;
  late final TextEditingController _discountPercent;
  late final TextEditingController _technicianNote;
  String _animalType = AiTechnicianAnimalTypes.values.first;
  bool _followUp = false;
  bool _isAvailable = true;
  bool _loading = true;
  String? _loadError;
  bool _saving = false;
  AiTechnicianServiceRow? _existing;

  bool get _isEdit => widget.serviceId != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _breed = TextEditingController();
    _description = TextEditingController();
    _basePrice = TextEditingController();
    _visitFee = TextEditingController();
    _emergencyFee = TextEditingController();
    _repeatPolicy = TextEditingController();
    _offerPrice = TextEditingController();
    _discountPercent = TextEditingController();
    _technicianNote = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _title.dispose();
    _breed.dispose();
    _description.dispose();
    _basePrice.dispose();
    _visitFee.dispose();
    _emergencyFee.dispose();
    _repeatPolicy.dispose();
    _offerPrice.dispose();
    _discountPercent.dispose();
    _technicianNote.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!_isEdit) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await ref
          .read(aiTechnicianRepositoryProvider)
          .listServices();
      final id = widget.serviceId!;
      AiTechnicianServiceRow? row;
      for (final e in list) {
        if (e.id == id) {
          row = e;
          break;
        }
      }
      if (!mounted) return;
      if (row == null) {
        setState(() {
          _loadError = 'সার্ভিস খুঁজে পাওয়া যায়নি';
          _loading = false;
        });
        return;
      }
      _existing = row;
      _title.text = row.title;
      _breed.text = row.breedOrSemenType ?? '';
      _description.text = row.description ?? '';
      _basePrice.text = row.basePrice;
      _visitFee.text = row.visitFee ?? '';
      _emergencyFee.text = row.emergencyFee ?? '';
      _repeatPolicy.text = row.repeatServicePolicy ?? '';
      _animalType = row.animalType;
      _followUp = row.followUpIncluded;
      _isAvailable = row.isAvailable;
      _offerPrice.text = row.offerPrice ?? '';
      _discountPercent.text = row.discountPercent ?? '';
      _technicianNote.text = row.technicianServiceNote ?? '';
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e is AiTechnicianApiException
            ? e.message
            : 'সার্ভিস তথ্য লোড করা যায়নি। আবার চেষ্টা করুন।';
        _loading = false;
      });
    }
  }

  AiTechnicianServiceRow _draftFromForm() {
    return AiTechnicianServiceRow(
      id: _existing?.id ?? '',
      aiTechnicianId: _existing?.aiTechnicianId,
      title: _title.text,
      animalType: _animalType,
      breedOrSemenType: _breed.text.trim().isEmpty ? null : _breed.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      basePrice: _basePrice.text.trim(),
      visitFee: _visitFee.text.trim().isEmpty ? null : _visitFee.text.trim(),
      emergencyFee: _emergencyFee.text.trim().isEmpty
          ? null
          : _emergencyFee.text.trim(),
      repeatServicePolicy: _repeatPolicy.text.trim().isEmpty
          ? null
          : _repeatPolicy.text.trim(),
      followUpIncluded: _followUp,
      status: _existing?.status ?? 'DRAFT',
      createdAt: _existing?.createdAt ?? '',
      updatedAt: _existing?.updatedAt ?? '',
      semenServiceTemplateId: _existing?.semenServiceTemplateId,
      offerPrice: _offerPrice.text.trim().isEmpty ? null : _offerPrice.text.trim(),
      discountPercent:
          _discountPercent.text.trim().isEmpty ? null : _discountPercent.text.trim(),
      isAvailable: _isAvailable,
      technicianServiceNote:
          _technicianNote.text.trim().isEmpty ? null : _technicianNote.text.trim(),
      stockSummary: _existing?.stockSummary,
      semenTemplateLocked: _existing?.semenTemplateLocked,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final draft = _draftFromForm();
      final body = _isEdit ? draft.toPatchBody() : draft.toCreateBody();
      if (_isEdit) {
        await ref
            .read(aiTechnicianRepositoryProvider)
            .patchService(widget.serviceId!, body);
      } else {
        await ref.read(aiTechnicianRepositoryProvider).createService(body);
      }
      ref.invalidate(aiTechnicianServicesListProvider);
      ref.invalidate(aiTechnicianDashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('সংরক্ষিত হয়েছে')));
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is AiTechnicianApiException ? e.message : 'সংরক্ষণ ব্যর্থ';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deactivate() async {
    if (!_isEdit || _existing == null) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('সার্ভিস নিষ্ক্রিয় করবেন?'),
        content: const Text(
          'নিষ্ক্রিয় করা হলে এটি আর গ্রাহকদের কাছে সক্রিয় থাকবে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(aiTechnicianRepositoryProvider)
          .deactivateService(widget.serviceId!);
      ref.invalidate(aiTechnicianServicesListProvider);
      ref.invalidate(aiTechnicianDashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সার্ভিস নিষ্ক্রিয় করা হয়েছে')),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is AiTechnicianApiException ? e.message : 'ব্যর্থ হয়েছে';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final editable = _existing == null || _existing!.isEditable;
    final templateLocked = _existing?.isTemplateBacked ?? false;
    final editableCatalog = editable && !templateLocked;

    return PraniScaffold(
      title: _isEdit ? 'সার্ভিস সম্পাদনা' : 'নতুন সার্ভিস',
      resizeToAvoidBottomInset: true,
      padding: EdgeInsets.zero,
      body: _loading
          ? const Center(
              child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
            )
          : _loadError != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: PraniErrorState(
                  title: 'লোড করা যায়নি',
                  message: _loadError!,
                  retryLabel: 'আবার চেষ্টা',
                  onRetry: _bootstrap,
                  boxed: true,
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  PraniSpacing.md,
                  hPad,
                  PraniSpacing.xl + kb + 32,
                ),
                children: [
                  if (_isEdit && _existing != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: PraniSpacing.md),
                      child: PraniFormCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('অবস্থা'),
                          subtitle: Text(
                            AiTechnicianServiceStatusCopy.titleBn(
                              _existing!.status,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_isEdit && _existing != null && templateLocked)
                    Padding(
                      padding: const EdgeInsets.only(bottom: PraniSpacing.md),
                      child: PraniFormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'টেমপ্লেট সার্ভিস',
                              style: textTheme.titleSmall,
                            ),
                            const SizedBox(height: PraniSpacing.sm),
                            Text(
                              _existing!.semenTemplateLocked?['internalName']
                                      ?.toString() ??
                                  _existing!.title,
                            ),
                            if (_existing!.stockSummary != null) ...[
                              const SizedBox(height: PraniSpacing.sm),
                              Text(
                                'স্টক: উপলব্ধ ${_existing!.stockSummary!.totalAvailable} '
                                '(${_existing!.stockSummary!.lotsCount} লট)',
                              ),
                            ],
                            const SizedBox(height: PraniSpacing.sm),
                            PraniSecondaryButton(
                              label: 'স্টক লট পরিচালনা',
                              fullWidth: true,
                              onPressed: () => context.push(
                                '${AiTechnicianServicesListScreen.routePath}/${_existing!.id}/semen-inventory',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isEdit && _existing != null && !editable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: PraniSpacing.md),
                      child: Text(
                        'এই অবস্থায় সম্পাদনা বন্ধ। শুধু নিষ্ক্রিয় করা যেতে পারে।',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  PraniFormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PraniTextField(
                          controller: _title,
                          enabled: editableCatalog && !_saving,
                          decoration: const InputDecoration(
                            labelText: 'সার্ভিসের শিরোনাম',
                            hintText: 'কৃত্রিম প্রজনন সেবা',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'শিরোনাম লিখুন';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: PraniFormTokens.fieldGap),
                        PraniDropdownField<String>(
                          value: _animalType,
                          enabled: editableCatalog && !_saving,
                          decoration: const InputDecoration(
                            labelText: 'প্রাণীর ধরন',
                          ),
                          items: AiTechnicianAnimalTypes.values
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    AiTechnicianAnimalTypes.labelBn(c),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (!editableCatalog || _saving)
                              ? null
                              : (v) {
                                  if (v != null) {
                                    setState(() => _animalType = v);
                                  }
                                },
                        ),
                        SizedBox(height: PraniFormTokens.fieldGap),
                        PraniTextField(
                          controller: _breed,
                          enabled: editableCatalog && !_saving,
                          decoration: const InputDecoration(
                            labelText: 'জাত / সিমেন টাইপ (ঐচ্ছিক)',
                          ),
                        ),
                        SizedBox(height: PraniFormTokens.fieldGap),
                        PraniTextArea(
                          controller: _description,
                          enabled: editableCatalog && !_saving,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'বিবরণ',
                            alignLabelWithHint: true,
                          ),
                        ),
                        SizedBox(height: PraniFormTokens.fieldGap),
                        PraniTextField(
                          controller: _basePrice,
                          enabled: editable && !_saving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'বেস ফি (৳)',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'মূল্য লিখুন';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: PraniFormTokens.fieldGap),
                        PraniTextField(
                          controller: _visitFee,
                          enabled: editable && !_saving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'ভিজিট ফি (৳, ঐচ্ছিক)',
                          ),
                        ),
                        SizedBox(height: PraniFormTokens.fieldGap),
                        PraniTextField(
                          controller: _emergencyFee,
                          enabled: editable && !_saving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'জরুরি সেবা ফি (৳, ঐচ্ছিক)',
                          ),
                        ),
                        if (templateLocked) ...[
                          SizedBox(height: PraniFormTokens.fieldGap),
                          PraniTextField(
                            controller: _offerPrice,
                            enabled: editable && !_saving,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'অফার মূল্য (৳, ঐচ্ছিক)',
                            ),
                          ),
                          SizedBox(height: PraniFormTokens.fieldGap),
                          PraniTextField(
                            controller: _discountPercent,
                            enabled: editable && !_saving,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'ছাড় % (ঐচ্ছিক)',
                            ),
                          ),
                          SizedBox(height: PraniFormTokens.fieldGap),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('গ্রাহকের কাছে উপলব্ধ'),
                            value: _isAvailable,
                            onChanged: (!editable || _saving)
                                ? null
                                : (v) => setState(() => _isAvailable = v),
                          ),
                          SizedBox(height: PraniFormTokens.fieldGap),
                          PraniTextArea(
                            controller: _technicianNote,
                            enabled: editable && !_saving,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'ব্যক্তিগত নোট (ঐচ্ছিক)',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                        SizedBox(height: PraniFormTokens.fieldGap),
                        PraniTextArea(
                          controller: _repeatPolicy,
                          enabled: editable && !_saving,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'পুনরায় সেবার নীতি',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.sm),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('ফলোআপ অন্তর্ভুক্ত'),
                          value: _followUp,
                          onChanged: (!editable || _saving)
                              ? null
                              : (v) => setState(() => _followUp = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.lg),
                  if (editable)
                    PraniPrimaryButton(
                      label: 'সংরক্ষণ করুন',
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  if (_isEdit &&
                      _existing != null &&
                      _existing!.status != 'INACTIVE') ...[
                    const SizedBox(height: PraniSpacing.sm),
                    PraniSecondaryButton(
                      label: 'সার্ভিস নিষ্ক্রিয় করুন',
                      fullWidth: true,
                      isLoading: _saving,
                      onPressed: _saving ? null : _deactivate,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
