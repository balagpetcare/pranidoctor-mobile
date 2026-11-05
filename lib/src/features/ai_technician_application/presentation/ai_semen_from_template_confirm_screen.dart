import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_error_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_fields.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_services_list_screen.dart';

class AiSemenFromTemplateConfirmScreen extends ConsumerStatefulWidget {
  const AiSemenFromTemplateConfirmScreen({super.key, required this.templateId});

  final String templateId;

  static const routePath = '/profile/ai-technician/semen-templates';

  @override
  ConsumerState<AiSemenFromTemplateConfirmScreen> createState() =>
      _AiSemenFromTemplateConfirmScreenState();
}

class _AiSemenFromTemplateConfirmScreenState
    extends ConsumerState<AiSemenFromTemplateConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _basePrice = TextEditingController();
  final _offer = TextEditingController();
  final _discount = TextEditingController();
  final _visit = TextEditingController();
  final _emergency = TextEditingController();
  final _note = TextEditingController();
  final _stockQty = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  SemenTemplateCatalogRow? _t;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _emergencyEnabled = false;
  bool _repeatVisit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _basePrice.dispose();
    _offer.dispose();
    _discount.dispose();
    _visit.dispose();
    _emergency.dispose();
    _note.dispose();
    _stockQty.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final t = await ref
          .read(aiTechnicianRepositoryProvider)
          .getSemenTemplate(widget.templateId);
      if (!mounted) return;
      _basePrice.text = t.defaultBasePrice;
      if (t.defaultOfferPrice != null) {
        _offer.text = t.defaultOfferPrice!;
      }
      if (t.defaultDiscountPercent != null) {
        _discount.text = t.defaultDiscountPercent!;
      }
      _visit.text = '';
      _emergency.text = '';
      setState(() {
        _t = t;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is AiTechnicianApiException ? e.message : 'লোড করা যায়নি';
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final t = _t;
    if (t == null) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }
    final hasOffer = _offer.text.trim().isNotEmpty;
    final hasDisc = _discount.text.trim().isNotEmpty;
    if (hasOffer && hasDisc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AiSemenConfirmCopy.offerDiscountConflict),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'templateId': t.id,
        'basePrice': _basePrice.text.trim().isEmpty ? null : _basePrice.text.trim(),
        'offerPrice': hasOffer ? _offer.text.trim() : null,
        'discountPercent': hasDisc ? _discount.text.trim() : null,
        'visitFee': _visit.text.trim().isEmpty ? null : _visit.text.trim(),
        'emergencyFee':
            _emergency.text.trim().isEmpty ? null : _emergency.text.trim(),
        'technicianServiceNote':
            _note.text.trim().isEmpty ? null : _note.text.trim(),
        'isAvailable': true,
      };
      final qty = int.tryParse(_stockQty.text.trim());
      if (qty != null && qty >= 0) {
        body['initialInventoryLot'] = <String, dynamic>{
          'currentQuantity': qty,
        };
      }
      await ref
          .read(aiTechnicianRepositoryProvider)
          .createServiceFromTemplate(body);
      ref.invalidate(aiTechnicianServicesListProvider);
      ref.invalidate(aiTechnicianDashboardProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AiSemenConfirmCopy.createdDraftToast)),
      );
      context.go(AiTechnicianServicesListScreen.routePath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AiTechnicianApiException ? e.message : 'ব্যর্থ'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double? _tryParse(String raw) {
    if (raw.trim().isEmpty) return null;
    return double.tryParse(raw.replaceAll(',', ''));
  }

  String? _requiredPriceValidator(String? value) {
    final v = _tryParse(value ?? '');
    if (v == null) return AiSemenConfirmCopy.requiredField;
    if (v < 0) return AiSemenConfirmCopy.invalidValue;
    return null;
  }

  String? _optionalNumberValidator(String? value) {
    final v = _tryParse(value ?? '');
    if (v == null && (value ?? '').trim().isNotEmpty) {
      return AiSemenConfirmCopy.invalidValue;
    }
    if (v != null && v < 0) return AiSemenConfirmCopy.invalidValue;
    return null;
  }

  double? _effectivePrice() {
    final base = _tryParse(_basePrice.text);
    if (base == null) return null;
    final offer = _tryParse(_offer.text);
    final discount = _tryParse(_discount.text);
    if (offer != null) return offer;
    if (discount != null) {
      return base - (base * discount / 100);
    }
    return base;
  }

  void _applySmartVisit() {
    if (_repeatVisit && _visit.text.trim().isEmpty) {
      _visit.text = '0';
    }
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PraniTextStyles.sectionTitleProminent(
              Theme.of(context).colorScheme,
              Theme.of(context).textTheme,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: PraniSpacing.xs),
            Text(
              subtitle,
              style: PraniTextStyles.bodyMuted(
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
              ),
            ),
          ],
          const SizedBox(height: PraniSpacing.lg),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final t = _t;
    return PraniScaffold(
      title: AiSemenConfirmCopy.screenTitle,
      padding: EdgeInsets.zero,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: t == null
          ? null
          : _StickySubmitBar(
              saving: _saving,
              onSubmit: _submit,
              summary: _effectivePrice(),
            ),
      body: _loading
          ? const Center(
              child: PraniLoadingState(message: AiSemenConfirmCopy.loading, compact: false),
            )
          : _error != null || t == null
              ? Center(
                  child: PraniErrorState(
                    title: AiSemenConfirmCopy.loadErrorTitle,
                    message: _error ?? AiSemenConfirmCopy.notFound,
                    retryLabel: AiSemenConfirmCopy.loadErrorRetry,
                    onRetry: _load,
                    boxed: true,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    PraniSpacing.md,
                    hPad,
                    PraniSpacing.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _ServiceSummaryHeader(template: t),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: PraniSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: _buildSection(
                              context: context,
                              title: AiSemenConfirmCopy.pricingTitle,
                              subtitle: AiSemenConfirmCopy.pricingSubtitle,
                              child: Column(
                                children: [
                                  _PriceSummaryCard(
                                    basePrice: _tryParse(_basePrice.text),
                                    offerPrice: _tryParse(_offer.text),
                                    discount: _tryParse(_discount.text),
                                    effectivePrice: _effectivePrice(),
                                  ),
                                  const SizedBox(height: PraniSpacing.lg),
                                  PraniTextField(
                                    controller: _basePrice,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]'),
                                      ),
                                    ],
                                    validator: _requiredPriceValidator,
                                    decoration: InputDecoration(
                                      labelText: AiSemenConfirmCopy.basePriceLabel,
                                      helperText:
                                          AiSemenConfirmCopy.basePriceHelper,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  PraniTextField(
                                    controller: _offer,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]'),
                                      ),
                                    ],
                                    validator: _optionalNumberValidator,
                                    decoration: InputDecoration(
                                      labelText: AiSemenConfirmCopy.offerLabel,
                                      helperText: AiSemenConfirmCopy.offerHelper,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  PraniTextField(
                                    controller: _discount,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]'),
                                      ),
                                    ],
                                    validator: _optionalNumberValidator,
                                    decoration: InputDecoration(
                                      labelText: AiSemenConfirmCopy.discountLabel,
                                      helperText:
                                          AiSemenConfirmCopy.discountHelper,
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  _QuickChipRow(
                                    title: AiSemenConfirmCopy.quickDiscountTitle,
                                    chips: AiSemenConfirmCopy.quickDiscountChips,
                                    onTap: (v) =>
                                        setState(() => _discount.text = v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: PraniSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: _buildSection(
                              context: context,
                              title: AiSemenConfirmCopy.visitTitle,
                              subtitle: AiSemenConfirmCopy.visitSubtitle,
                              child: Column(
                                children: [
                                  _ToggleTile(
                                    title: AiSemenConfirmCopy.repeatVisitTitle,
                                    subtitle:
                                        AiSemenConfirmCopy.repeatVisitSubtitle,
                                    value: _repeatVisit,
                                    onChanged: (v) {
                                      setState(() => _repeatVisit = v);
                                      _applySmartVisit();
                                    },
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  PraniTextField(
                                    controller: _visit,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]'),
                                      ),
                                    ],
                                    validator: _optionalNumberValidator,
                                    decoration: InputDecoration(
                                      labelText: AiSemenConfirmCopy.visitFeeLabel,
                                      helperText:
                                          AiSemenConfirmCopy.visitFeeHelper,
                                    ),
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  _ToggleTile(
                                    title: AiSemenConfirmCopy.emergencyTitle,
                                    subtitle:
                                        AiSemenConfirmCopy.emergencySubtitle,
                                    value: _emergencyEnabled,
                                    onChanged: (v) =>
                                        setState(() => _emergencyEnabled = v),
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  AnimatedSwitcher(
                                    duration: PraniDurations.short,
                                    child: _emergencyEnabled
                                        ? PraniTextField(
                                            key: const ValueKey('emergencyFee'),
                                            controller: _emergency,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[\d.]'),
                                              ),
                                            ],
                                            validator: _optionalNumberValidator,
                                            decoration: InputDecoration(
                                              labelText: AiSemenConfirmCopy
                                                  .emergencyFeeLabel,
                                              helperText: AiSemenConfirmCopy
                                                  .emergencyFeeHelper,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: PraniSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: _buildSection(
                              context: context,
                              title: AiSemenConfirmCopy.strawTitle,
                              subtitle: AiSemenConfirmCopy.strawSubtitle,
                              child: Column(
                                children: [
                                  _QuickChipRow(
                                    title: AiSemenConfirmCopy.doseSuggestionTitle,
                                    chips: AiSemenConfirmCopy.doseSuggestionChips,
                                    onTap: (v) => setState(() {
                                      _stockQty.text = v;
                                    }),
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  PraniTextField(
                                    controller: _stockQty,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: _optionalNumberValidator,
                                    decoration: InputDecoration(
                                      labelText: AiSemenConfirmCopy.strawLabel,
                                      helperText: AiSemenConfirmCopy.strawHelper,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: PraniSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: _ExpandableSection(
                              title: AiSemenConfirmCopy.clinicalNotesTitle,
                              subtitle: AiSemenConfirmCopy.clinicalNotesSubtitle,
                              child: Column(
                                children: [
                                  _QuickChipRow(
                                    title:
                                        AiSemenConfirmCopy.notesAssistantTitle,
                                    chips: AiSemenConfirmCopy.noteSuggestions,
                                    onTap: (v) => setState(() {
                                      _note.text =
                                          _note.text.trim().isEmpty
                                              ? v
                                              : '${_note.text.trim()} · $v';
                                    }),
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  PraniTextArea(
                                    controller: _note,
                                    minLines: 3,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      labelText:
                                          AiSemenConfirmCopy.notesLabel,
                                      helperText:
                                          AiSemenConfirmCopy.notesHelper,
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: PraniSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: _ExpandableSection(
                              title: AiSemenConfirmCopy.aiTitle,
                              subtitle: AiSemenConfirmCopy.aiSubtitle,
                              child: Column(
                                children: [
                                  _AiRecommendationCard(
                                    title: AiSemenConfirmCopy.aiPriceTitle,
                                    message: AiSemenConfirmCopy.aiPriceMessage,
                                    actionLabel:
                                        AiSemenConfirmCopy.aiApplySuggestion,
                                    onPressed: () {
                                      _basePrice.text = t.defaultBasePrice;
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(height: PraniSpacing.md),
                                  _AiRecommendationCard(
                                    title: AiSemenConfirmCopy.aiVisitTitle,
                                    message: AiSemenConfirmCopy.aiVisitMessage,
                                    actionLabel:
                                        AiSemenConfirmCopy.aiApplySuggestion,
                                    onPressed: () {
                                      _visit.text = _visit.text.trim().isEmpty
                                          ? '0'
                                          : _visit.text;
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: PraniSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: _ExpandableSection(
                              title: AiSemenConfirmCopy.reviewTitle,
                              subtitle: AiSemenConfirmCopy.reviewSubtitle,
                              child: _FinalReviewCard(
                                basePrice: _basePrice.text,
                                offer: _offer.text,
                                discount: _discount.text,
                                visitFee: _visit.text,
                                emergencyFee: _emergencyEnabled
                                    ? _emergency.text
                                    : '',
                                strawUsage: _stockQty.text,
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: PraniSpacing.xxl),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class AiSemenConfirmCopy {
  static const String screenTitle = 'সার্ভিস লঞ্চার';
  static const String loading = 'লোড হচ্ছে…';
  static const String notFound = 'পাওয়া যায়নি';
  static const String loadErrorTitle = 'লোড করা যায়নি';
  static const String loadErrorRetry = 'আবার চেষ্টা';
  static const String offerDiscountConflict = 'অফার মূল্য ও ছাড় একসাথে দেওয়া যাবে না';
  static const String createdDraftToast = 'সার্ভিস তৈরি হয়েছে (খসড়া)';
  static const String requiredField = 'ফিল্ডটি পূরণ করুন';
  static const String invalidValue = 'সঠিক মান দিন';

  static const String pricingTitle = 'প্রাইসিং ও প্যাকেজ';
  static const String pricingSubtitle = 'স্মার্ট প্রাইস কনফিগারেশন';
  static const String basePriceLabel = 'বেস মূল্য (৳)';
  static const String basePriceHelper = 'AI সুপারিশ অনুযায়ী বেস মূল্য দিন';
  static const String offerLabel = 'অফার মূল্য (৳)';
  static const String offerHelper = 'একটি অফার মূল্য হলে ছাড় দিন না';
  static const String discountLabel = 'ছাড় (%)';
  static const String discountHelper = 'শুধু ছাড় বা অফার যে কোনো একটি দিন';
  static const String quickDiscountTitle = 'দ্রুত ছাড় সেট করুন';
  static const List<String> quickDiscountChips = ['5', '10', '15'];

  static const String visitTitle = 'ভিজিট কন্ডিশন';
  static const String visitSubtitle = 'পরিদর্শন পরিস্থিতি ও জরুরি কভারেজ';
  static const String repeatVisitTitle = 'রিপিট ভিজিট';
  static const String repeatVisitSubtitle = 'পূর্ববর্তী ভিজিট হলে দ্রুত সেট করুন';
  static const String visitFeeLabel = 'ভিজিট ফি (৳)';
  static const String visitFeeHelper = 'ভিজিট ফি না থাকলে শূন্য দিন';
  static const String emergencyTitle = 'জরুরি সেবা';
  static const String emergencySubtitle = 'জরুরি ক্ষেত্রে অতিরিক্ত চার্জ চালু করুন';
  static const String emergencyFeeLabel = 'জরুরি ফি (৳)';
  static const String emergencyFeeHelper = 'জরুরি ফি নির্ধারণ করুন';

  static const String strawTitle = 'স্ট্রো ব্যবহার';
  static const String strawSubtitle = 'সিমেন স্ট্রো ও ইনভেন্টরি';
  static const String strawLabel = 'স্ট্রো সংখ্যা (ঐচ্ছিক)';
  static const String strawHelper = 'প্রাথমিক স্টক বা ব্যবহার সংখ্যা দিন';
  static const String doseSuggestionTitle = 'ডোজ সাজেশন';
  static const List<String> doseSuggestionChips = ['1', '2', '3'];

  static const String clinicalNotesTitle = 'ক্লিনিক্যাল নোট';
  static const String clinicalNotesSubtitle = 'ফিল্ড নোট ও পরিকল্পনা';
  static const String notesAssistantTitle = 'টেকনিশিয়ান নোট সহায়ক';
  static const String notesLabel = 'টেকনিশিয়ান নোট';
  static const String notesHelper = 'শর্ট নোট লিখুন (AI সহায়ক প্রস্তুত)';
  static const List<String> noteSuggestions = [
    'পশু শান্ত ছিল',
    'পরিচ্ছন্ন পরিবেশ',
    'প্রধান ভেট অনুমোদন',
  ];

  static const String aiTitle = 'AI রেকমেন্ডেশন';
  static const String aiSubtitle = 'স্মার্ট সাজেশন ব্যবহার করুন';
  static const String aiPriceTitle = 'AI প্রাইসিং';
  static const String aiPriceMessage = 'টেমপ্লেট বেস প্রাইস ব্যবহার করুন';
  static const String aiVisitTitle = 'AI ভিজিট সাজেশন';
  static const String aiVisitMessage = 'রিপিট ভিজিটে ফি শূন্য রাখুন';
  static const String aiApplySuggestion = 'প্রয়োগ করুন';

  static const String reviewTitle = 'ফাইনাল রিভিউ';
  static const String reviewSubtitle = 'চূড়ান্ত যাচাই';
  static const String launchLabel = 'সার্ভিস শুরু করুন';
  static const String summaryTitle = 'সার্ভিস সারাংশ';
  static const String summaryAnimalLabel = 'প্রাণী';
  static const String summaryBreedLabel = 'জাত';
  static const String summaryBaseLabel = 'বেস';
  static const String summaryOfferLabel = 'অফার';
  static const String summaryDiscountLabel = 'ছাড় %';
  static const String summaryFinalLabel = 'চূড়ান্ত';
  static const String reviewBaseLabel = 'বেস মূল্য';
  static const String reviewOfferLabel = 'অফার মূল্য';
  static const String reviewDiscountLabel = 'ছাড় %';
  static const String reviewVisitLabel = 'ভিজিট ফি';
  static const String reviewEmergencyLabel = 'জরুরি ফি';
  static const String reviewStrawLabel = 'স্ট্রো';
}

class _ServiceSummaryHeader extends StatelessWidget {
  const _ServiceSummaryHeader({required this.template});

  final SemenTemplateCatalogRow template;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AiSemenConfirmCopy.summaryTitle,
            style: PraniTextStyles.sectionTitleProminent(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.sm),
          Text(
            template.internalName,
            style: PraniTextStyles.pageTitleProminent(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.xs),
          Text(
            template.semenProvider.name,
            style: PraniTextStyles.bodyMuted(
              scheme,
              Theme.of(context).textTheme,
            ),
          ),
          const SizedBox(height: PraniSpacing.md),
          _InfoRow(
            label: AiSemenConfirmCopy.summaryAnimalLabel,
            value: template.animalType,
          ),
          const SizedBox(height: PraniSpacing.sm),
          _InfoRow(
            label: AiSemenConfirmCopy.summaryBreedLabel,
            value:
                template.breedSummaryBn.isEmpty ? '-' : template.breedSummaryBn,
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({
    required this.basePrice,
    required this.offerPrice,
    required this.discount,
    required this.effectivePrice,
  });

  final double? basePrice;
  final double? offerPrice;
  final double? discount;
  final double? effectivePrice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AiSemenConfirmCopy.pricingTitle,
            style: PraniTextStyles.subheading(scheme, textTheme),
          ),
          const SizedBox(height: PraniSpacing.sm),
          _SummaryRow(
            label: AiSemenConfirmCopy.summaryBaseLabel,
            value: _formatNumber(basePrice),
          ),
          _SummaryRow(
            label: AiSemenConfirmCopy.summaryOfferLabel,
            value: _formatNumber(offerPrice),
          ),
          _SummaryRow(
            label: AiSemenConfirmCopy.summaryDiscountLabel,
            value: _formatNumber(discount),
          ),
          const SizedBox(height: PraniSpacing.sm),
          _SummaryRow(
            label: AiSemenConfirmCopy.summaryFinalLabel,
            value: _formatNumber(effectivePrice),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PraniTextStyles.subheading(
                    Theme.of(context).colorScheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  subtitle,
                  style: PraniTextStyles.bodyMuted(
                    Theme.of(context).colorScheme,
                    Theme.of(context).textTheme,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _QuickChipRow extends StatelessWidget {
  const _QuickChipRow({
    required this.title,
    required this.chips,
    required this.onTap,
  });

  final String title;
  final List<String> chips;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PraniTextStyles.label(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        const SizedBox(height: PraniSpacing.xs),
        Wrap(
          spacing: PraniSpacing.sm,
          children: chips
              .map(
                (chip) => ActionChip(
                  label: Text(chip),
                  onPressed: () => onTap(chip),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AiRecommendationCard extends StatelessWidget {
  const _AiRecommendationCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PraniSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(PraniRadius.md),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: scheme.primary),
          const SizedBox(width: PraniSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PraniTextStyles.subheading(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
                const SizedBox(height: PraniSpacing.xs),
                Text(
                  message,
                  style: PraniTextStyles.bodyMuted(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(PraniRadius.lg),
        boxShadow: PraniShadows.elevatedCardShadow(
          Theme.of(context).brightness,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: PraniTextStyles.subheading(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: PraniTextStyles.bodyMuted(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        tilePadding: const EdgeInsets.all(PraniSpacing.xl),
        childrenPadding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          0,
          PraniSpacing.xl,
          PraniSpacing.xl,
        ),
        children: [child],
      ),
    );
  }
}

class _FinalReviewCard extends StatelessWidget {
  const _FinalReviewCard({
    required this.basePrice,
    required this.offer,
    required this.discount,
    required this.visitFee,
    required this.emergencyFee,
    required this.strawUsage,
  });

  final String basePrice;
  final String offer;
  final String discount;
  final String visitFee;
  final String emergencyFee;
  final String strawUsage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryRow(label: AiSemenConfirmCopy.reviewBaseLabel, value: basePrice),
        _SummaryRow(
          label: AiSemenConfirmCopy.reviewOfferLabel,
          value: offer,
        ),
        _SummaryRow(
          label: AiSemenConfirmCopy.reviewDiscountLabel,
          value: discount,
        ),
        _SummaryRow(
          label: AiSemenConfirmCopy.reviewVisitLabel,
          value: visitFee,
        ),
        _SummaryRow(
          label: AiSemenConfirmCopy.reviewEmergencyLabel,
          value: emergencyFee,
        ),
        _SummaryRow(
          label: AiSemenConfirmCopy.reviewStrawLabel,
          value: strawUsage,
        ),
      ],
    );
  }
}

class _StickySubmitBar extends StatelessWidget {
  const _StickySubmitBar({
    required this.saving,
    required this.onSubmit,
    required this.summary,
  });

  final bool saving;
  final VoidCallback onSubmit;
  final double? summary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.md,
          PraniSpacing.xl,
          PraniSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: PraniShadows.elevatedCardShadow(
            Theme.of(context).brightness,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AiSemenConfirmCopy.launchLabel,
                    style: PraniTextStyles.label(
                      Theme.of(context).colorScheme,
                      Theme.of(context).textTheme,
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.xs),
                  Text(
                    _formatNumber(summary),
                    style: PraniTextStyles.subheading(
                      Theme.of(context).colorScheme,
                      Theme.of(context).textTheme,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PraniSpacing.sm),
            PraniPrimaryButton(
              label: AiSemenConfirmCopy.launchLabel,
              isLoading: saving,
              onPressed: saving ? null : onSubmit,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PraniSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: PraniTextStyles.bodyMuted(
                scheme,
                Theme.of(context).textTheme,
              ),
            ),
          ),
          Text(
            value.isEmpty ? '-' : value,
            style: highlight
                ? PraniTextStyles.subheading(
                    scheme,
                    Theme.of(context).textTheme,
                  )
                : PraniTextStyles.body(
                    scheme,
                    Theme.of(context).textTheme,
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: PraniTextStyles.label(
              Theme.of(context).colorScheme,
              Theme.of(context).textTheme,
            ),
          ),
        ),
        const SizedBox(width: PraniSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: PraniTextStyles.body(
              Theme.of(context).colorScheme,
              Theme.of(context).textTheme,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double? value) {
  if (value == null) return '-';
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}
