import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/profile_photo_crop_flow.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/uploads/application/upload_providers.dart';
import 'package:pranidoctor_mobile/src/features/uploads/data/upload_repository.dart';
import 'package:pranidoctor_mobile/src/features/uploads/data/uploaded_file_model.dart';

enum ProfessionalProfileImageSlotKind {
  profilePhoto,
  certificate,
  identity,
  workSample,
}

/// Maps slot → server purpose (null = local-only until backend extends purposes).
String? professionalProfileImageUploadPurpose({
  required ProfessionalPersona persona,
  required ProfessionalProfileImageSlotKind kind,
}) {
  if (persona == ProfessionalPersona.veterinaryDoctor) {
    return switch (kind) {
      ProfessionalProfileImageSlotKind.profilePhoto =>
        MobileUploadPurpose.customerProfilePhoto,
      _ => null,
    };
  }
  return switch (kind) {
    ProfessionalProfileImageSlotKind.profilePhoto =>
      MobileUploadPurpose.aiTechnicianProfilePhoto,
    ProfessionalProfileImageSlotKind.certificate =>
      MobileUploadPurpose.aiTechnicianTrainingCertificate,
    ProfessionalProfileImageSlotKind.identity =>
      MobileUploadPurpose.aiTechnicianNidFront,
    ProfessionalProfileImageSlotKind.workSample =>
      MobileUploadPurpose.aiTechnicianOther,
  };
}

/// Pick → crop → compress → preview; optional S3 upload when purpose resolves non-null.
class ProfessionalProfileImageSlotCard extends ConsumerStatefulWidget {
  const ProfessionalProfileImageSlotCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.persona,
    required this.slotKind,
    required this.localPath,
    required this.uploadedFileId,
    required this.onLocalPathChanged,
    required this.onUploadedFileIdChanged,
  });

  final String title;
  final String subtitle;
  final ProfessionalPersona persona;
  final ProfessionalProfileImageSlotKind slotKind;
  final String? localPath;
  final String? uploadedFileId;
  final ValueChanged<String?> onLocalPathChanged;
  final ValueChanged<String?> onUploadedFileIdChanged;

  @override
  ConsumerState<ProfessionalProfileImageSlotCard> createState() =>
      _ProfessionalProfileImageSlotCardState();
}

class _ProfessionalProfileImageSlotCardState
    extends ConsumerState<ProfessionalProfileImageSlotCard> {
  bool _busy = false;

  Future<void> _pick() async {
    final src = await ProfilePhotoCropFlow.showPickImageSourceSheet(context);
    if (src == null || !mounted) return;
    final path = await ProfilePhotoCropFlow.pickCropProfilePhoto(context, src);
    if (!mounted) return;
    widget.onLocalPathChanged(path);
    widget.onUploadedFileIdChanged(null);
  }

  Future<void> _upload() async {
    final purpose = professionalProfileImageUploadPurpose(
      persona: widget.persona,
      kind: widget.slotKind,
    );
    final path = widget.localPath;
    if (purpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'এই স্লটের জন্য সার্ভার আপলোড টাইপ এখনও সক্রিয় নয় — লোকাল ড্রাফট সংরক্ষিত।',
          ),
        ),
      );
      return;
    }
    if (path == null || !File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আগে ছবি বেছে নিন।')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(uploadRepositoryProvider);
      final name = path.split(RegExp(r'[\\/]')).last;
      final res = await repo.uploadMobileFile(
        purpose: purpose,
        filePath: path,
        fileName: name,
      );
      if (!mounted) return;
      widget.onUploadedFileIdChanged(res.fileId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আপলোড সম্পন্ন')),
      );
    } on UploadApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('আপলোড ব্যর্থ: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasPreview =
        widget.localPath != null && File(widget.localPath!).existsSync();

    return PraniPremiumCard(
      padding: const EdgeInsets.all(PraniSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: PraniSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(PraniRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: hasPreview
                  ? Image.file(
                      File(widget.localPath!),
                      fit: BoxFit.cover,
                    )
                  : ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: scheme.outline,
                        ),
                      ),
                    ),
            ),
          ),
          if (widget.uploadedFileId != null) ...[
            const SizedBox(height: PraniSpacing.sm),
            Text(
              'ফাইল আইডি: ${widget.uploadedFileId}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                  ),
            ),
          ],
          const SizedBox(height: PraniSpacing.md),
          Row(
            children: [
              Expanded(
                child: PraniSecondaryButton(
                  label: 'বেছে নিন / ক্রপ',
                  onPressed: _busy ? null : _pick,
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: PraniSpacing.sm),
              Expanded(
                child: PraniPrimaryButton(
                  label: _busy ? 'আপলোড…' : 'আপলোড',
                  onPressed: _busy ? null : _upload,
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
