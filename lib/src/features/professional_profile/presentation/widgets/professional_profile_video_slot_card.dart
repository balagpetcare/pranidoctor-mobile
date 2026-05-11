import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';

/// Video pick for professional intro / gallery (upload pipeline = future purpose on server).
class ProfessionalProfileVideoSlotCard extends StatelessWidget {
  const ProfessionalProfileVideoSlotCard({
    super.key,
    required this.localPath,
    required this.onLocalPathChanged,
  });

  final String? localPath;
  final ValueChanged<String?> onLocalPathChanged;

  Future<void> _pick(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );
    final p = res?.files.single.path;
    if (p == null) return;
    onLocalPathChanged(p);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ভিডিও লোকাল ড্রাফটে সংরক্ষিত। সার্ভারে ভিডিও purpose যুক্ত হলে আপলোড চালু হবে।',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = localPath?.split(RegExp(r'[\\/]')).last ?? 'কোনো ভিডিও নয়';

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'পেশাদার ভিডিও',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: PraniSpacing.md),
          Row(
            children: [
              Expanded(
                child: PraniPrimaryButton(
                  label: 'ভিডিও বেছে নিন',
                  icon: Icons.video_file_outlined,
                  onPressed: () => _pick(context),
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: PraniSpacing.sm),
              Expanded(
                child: PraniSecondaryButton(
                  label: 'সরান',
                  onPressed: localPath == null ? null : () => onLocalPathChanged(null),
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
