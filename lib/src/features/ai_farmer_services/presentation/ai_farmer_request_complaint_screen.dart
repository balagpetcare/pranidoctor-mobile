import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/application/ai_farmer_services_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_farmer_services/data/ai_farmer_services_repository.dart';

/// Report an issue about an AI service request (assigned technician required).
class AiFarmerRequestComplaintScreen extends ConsumerStatefulWidget {
  const AiFarmerRequestComplaintScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AiFarmerRequestComplaintScreen> createState() =>
      _AiFarmerRequestComplaintScreenState();
}

class _AiFarmerRequestComplaintScreenState
    extends ConsumerState<AiFarmerRequestComplaintScreen> {
  final _category = TextEditingController();
  final _message = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _category.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cat = _category.text.trim();
    final msg = _message.text.trim();
    if (cat.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বিভাগ ও বর্ণনা পূরণ করুন।')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(aiFarmerServicesRepositoryProvider)
          .submitTechnicianComplaint(
            widget.requestId,
            category: cat,
            message: msg,
          );
      ref.invalidate(aiFarmerMyRequestDetailProvider(widget.requestId));
      ref.invalidate(aiMyServiceRequestsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অভিযোগ জমা হয়েছে। শীঘ্রই যোগাযোগ করা হবে।'),
        ),
      );
      context.pop();
    } on AiFarmerServicesApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('জমা দেওয়া যায়নি।\n$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: 'সমস্যা জানান',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: ListView(
        children: [
          PraniPremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আপনার অনুরোধ সম্পর্কে অভিযোগ বা প্রতিক্রিয়া লিখুন। টেকনিশিয়ান নির্ধারিত থাকলে অ্যাডমিন দেখবেন।',
                  style: textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: PraniSpacing.md),
                TextField(
                  controller: _category,
                  enabled: !_busy,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'বিভাগ (যেমন: সেবা / পেমেন্ট / আচরণ)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: PraniSpacing.sm),
                TextField(
                  controller: _message,
                  enabled: !_busy,
                  maxLines: 6,
                  maxLength: 4000,
                  decoration: const InputDecoration(
                    labelText: 'বিস্তারিত বর্ণনা',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PraniSpacing.md),
          PraniPrimaryButton(
            label: _busy ? 'জমা হচ্ছে…' : 'জমা দিন',
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
