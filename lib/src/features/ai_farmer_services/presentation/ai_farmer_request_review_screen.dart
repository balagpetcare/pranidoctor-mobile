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

/// Submit a one-time rating for a completed native AI service request.
class AiFarmerRequestReviewScreen extends ConsumerStatefulWidget {
  const AiFarmerRequestReviewScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AiFarmerRequestReviewScreen> createState() =>
      _AiFarmerRequestReviewScreenState();
}

class _AiFarmerRequestReviewScreenState
    extends ConsumerState<AiFarmerRequestReviewScreen> {
  int _rating = 5;
  final _comment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(aiFarmerServicesRepositoryProvider)
          .submitTechnicianReview(
            widget.requestId,
            rating: _rating,
            comment: _comment.text,
          );
      ref.invalidate(aiFarmerMyRequestDetailProvider(widget.requestId));
      ref.invalidate(aiMyServiceRequestsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('রিভিউ সংরক্ষিত হয়েছে। ধন্যবাদ!')),
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
      ).showSnackBar(SnackBar(content: Text('সংরক্ষণ করা যায়নি।\n$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: 'সেবার রিভিউ',
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
                  'সম্পন্ন সেবার জন্য রেটিং দিন (১–৫)',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PraniSpacing.sm),
                Row(
                  children: List.generate(5, (i) {
                    final n = i + 1;
                    final on = n <= _rating;
                    return IconButton(
                      tooltip: '$n',
                      icon: Icon(
                        on ? Icons.star : Icons.star_border,
                        color: on ? Colors.amber.shade800 : null,
                        size: 36,
                      ),
                      onPressed: _busy
                          ? null
                          : () => setState(() => _rating = n),
                    );
                  }),
                ),
                const SizedBox(height: PraniSpacing.sm),
                TextField(
                  controller: _comment,
                  enabled: !_busy,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    labelText: 'মন্তব্য (ঐচ্ছিক)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PraniSpacing.md),
          PraniPrimaryButton(
            label: _busy ? 'জমা হচ্ছে…' : 'রিভিউ জমা দিন',
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
