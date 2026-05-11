import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Stock lots for a template-backed semen service.
class AiSemenInventoryScreen extends ConsumerStatefulWidget {
  const AiSemenInventoryScreen({super.key, required this.serviceId});

  final String serviceId;

  static const routePath = '/profile/ai-technician/services';
  static String routeForService(String serviceId) =>
      '$routePath/$serviceId/semen-inventory';

  @override
  ConsumerState<AiSemenInventoryScreen> createState() =>
      _AiSemenInventoryScreenState();
}

class _AiSemenInventoryScreenState extends ConsumerState<AiSemenInventoryScreen> {
  bool _loading = true;
  String? _error;
  List<SemenInventoryLotRow> _lots = [];
  final _qty = TextEditingController();
  final _batch = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _qty.dispose();
    _batch.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref
          .read(aiTechnicianRepositoryProvider)
          .listSemenInventoryLots(widget.serviceId);
      if (!mounted) return;
      setState(() {
        _lots = list;
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

  Future<void> _addLot() async {
    final q = int.tryParse(_qty.text.trim());
    if (q == null || q < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক পরিমাণ লিখুন')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(aiTechnicianRepositoryProvider).createSemenInventoryLot(
            serviceId: widget.serviceId,
            body: <String, dynamic>{
              'currentQuantity': q,
              'batchNumber': _batch.text.trim().isEmpty
                  ? null
                  : _batch.text.trim(),
            },
          );
      _qty.clear();
      _batch.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('স্টক লাইন যোগ হয়েছে')),
        );
      }
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
    return PraniScaffold(
      title: 'সিমেন স্টক লট',
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
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  children: [
                    PraniFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'নতুন লট',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextField(
                            controller: _qty,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'বর্তমান পরিমাণ',
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.sm),
                          PraniTextField(
                            controller: _batch,
                            decoration: const InputDecoration(
                              labelText: 'ব্যাচ নম্বর (ঐচ্ছিক)',
                            ),
                          ),
                          const SizedBox(height: PraniSpacing.md),
                          PraniPrimaryButton(
                            label: 'যোগ করুন',
                            isLoading: _saving,
                            onPressed: _saving ? null : _addLot,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PraniSpacing.lg),
                    Text(
                      'বিদ্যমান লট (${_lots.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    ..._lots.map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(bottom: PraniSpacing.sm),
                        child: PraniFormCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l.batchNumber?.trim().isNotEmpty == true
                                  ? 'ব্যাচ: ${l.batchNumber}'
                                  : 'লট ${l.id.substring(0, 8)}…',
                            ),
                            subtitle: Text(
                              'পরিমাণ: ${l.currentQuantity} · রিজার্ভ: ${l.reservedQuantity}',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
