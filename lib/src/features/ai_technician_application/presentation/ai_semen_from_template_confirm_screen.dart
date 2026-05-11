import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_form_card.dart';
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
    final hasOffer = _offer.text.trim().isNotEmpty;
    final hasDisc = _discount.text.trim().isNotEmpty;
    if (hasOffer && hasDisc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অফার মূল্য ও ছাড় একসাথে দেওয়া যাবে না'),
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
        const SnackBar(content: Text('সার্ভিস তৈরি হয়েছে (খসড়া)')),
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

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final t = _t;
    return PraniScaffold(
      title: 'টেমপ্লেট থেকে সার্ভিস',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: _loading
          ? const Center(
              child: PraniLoadingState(message: 'লোড হচ্ছে…', compact: false),
            )
          : _error != null || t == null
              ? Center(child: Text(_error ?? 'পাওয়া যায়নি'))
              : ListView(
                  children: [
                    Text(
                      t.internalName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: PraniSpacing.md),
                    PraniFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PraniTextField(
                            controller: _basePrice,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'বেস মূল্য (৳)',
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextField(
                            controller: _offer,
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
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextField(
                            controller: _discount,
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
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextField(
                            controller: _visit,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'ভিজিট ফি (৳)',
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextField(
                            controller: _emergency,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'জরুরি ফি (৳)',
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextField(
                            controller: _stockQty,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'প্রথম স্টক পরিমাণ (ঐচ্ছিক)',
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextArea(
                            controller: _note,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'ব্যক্তিগত নোট (ঐচ্ছিক)',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.lg),
                    PraniPrimaryButton(
                      label: 'নিশ্চিত করুন',
                      isLoading: _saving,
                      onPressed: _saving ? null : _submit,
                    ),
                  ],
                ),
    );
  }
}
