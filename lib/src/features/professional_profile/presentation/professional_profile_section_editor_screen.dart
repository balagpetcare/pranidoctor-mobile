import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_technician_application_form_screen.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/application/professional_profile_draft_notifier.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/application/professional_profile_validators.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/data/professional_profile_draft.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_profile_section.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/widgets/prani_professional_validated_field.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/widgets/professional_profile_image_slot_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/presentation/widgets/professional_profile_video_slot_card.dart';
import 'package:pranidoctor_mobile/src/features/professional_verification/presentation/professional_verification_workflow_panel.dart';

/// Section editor — debounced draft persistence + validation hooks.
class ProfessionalProfileSectionEditorScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileSectionEditorScreen({
    super.key,
    required this.persona,
    required this.section,
  });

  final ProfessionalPersona persona;
  final ProfessionalProfileSection section;

  static const routePath = '/professional/profile/:persona/section/:section';

  static String routeLocation(
    ProfessionalPersona p,
    ProfessionalProfileSection s,
  ) =>
      '/professional/profile/${p.routeSegment}/section/${s.name}';

  @override
  ConsumerState<ProfessionalProfileSectionEditorScreen> createState() =>
      _ProfessionalProfileSectionEditorScreenState();
}

class _ProfessionalProfileSectionEditorScreenState
    extends ConsumerState<ProfessionalProfileSectionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _seeded = false;

  late final TextEditingController _displayName = TextEditingController();
  late final TextEditingController _publicBio = TextEditingController();
  late final TextEditingController _professionalTitle = TextEditingController();
  late final TextEditingController _license = TextEditingController();
  late final TextEditingController _providerCode = TextEditingController();
  late final TextEditingController _serviceAreas = TextEditingController();
  late final TextEditingController _availability = TextEditingController();
  late final TextEditingController _experience = TextEditingController();
  late final TextEditingController _education = TextEditingController();
  late final TextEditingController _pricing = TextEditingController();

  String? _displayNameError;
  String? _licenseError;
  String? _professionalTitleError;

  @override
  void dispose() {
    _displayName.dispose();
    _publicBio.dispose();
    _professionalTitle.dispose();
    _license.dispose();
    _providerCode.dispose();
    _serviceAreas.dispose();
    _availability.dispose();
    _experience.dispose();
    _education.dispose();
    _pricing.dispose();
    super.dispose();
  }

  void _seed(ProfessionalProfileDraft d) {
    if (_seeded) return;
    _seeded = true;
    _displayName.text = d.displayName;
    _publicBio.text = d.publicBio;
    _professionalTitle.text = d.professionalTitle;
    _license.text = d.licenseOrRegNumber;
    _providerCode.text = d.providerCode;
    _serviceAreas.text = d.serviceAreasCsv;
    _availability.text = d.availabilityNotes;
    _experience.text = d.experienceSummary;
    _education.text = d.educationSummary;
    _pricing.text = d.pricingNotes;
  }

  ProfessionalProfileDraft _currentDraftFromProvider() {
    final async = switch (widget.persona) {
      ProfessionalPersona.aiTechnician =>
        ref.read(aiTechnicianProfessionalDraftProvider),
      ProfessionalPersona.veterinaryDoctor =>
        ref.read(veterinaryDoctorProfessionalDraftProvider),
    };
    return switch (async) {
      AsyncData<ProfessionalProfileDraftSession>(:final value) => value.draft,
      _ => const ProfessionalProfileDraft(),
    };
  }

  void _commitFull() {
    final old = _currentDraftFromProvider();
    updateProfessionalDraft(ref, widget.persona, (_) => ProfessionalProfileDraft(
          displayName: _displayName.text,
          publicBio: _publicBio.text,
          professionalTitle: _professionalTitle.text,
          licenseOrRegNumber: _license.text,
          providerCode: _providerCode.text,
          serviceAreasCsv: _serviceAreas.text,
          availabilityNotes: _availability.text,
          experienceSummary: _experience.text,
          educationSummary: _education.text,
          pricingNotes: _pricing.text,
          profilePhotoLocalPath: old.profilePhotoLocalPath,
          profilePhotoUploadId: old.profilePhotoUploadId,
          certificateLocalPath: old.certificateLocalPath,
          certificateUploadId: old.certificateUploadId,
          identityLocalPath: old.identityLocalPath,
          identityUploadId: old.identityUploadId,
          workGalleryLocalPaths: old.workGalleryLocalPaths,
          workGalleryUploadIds: old.workGalleryUploadIds,
          introVideoLocalPath: old.introVideoLocalPath,
          introVideoUploadId: old.introVideoUploadId,
        ));
  }

  bool _validateHard() {
    if (widget.section == ProfessionalProfileSection.basic) {
      setState(() {
        _displayNameError = ProfessionalProfileValidators.requiredLine(
          _displayName.text,
        );
        _licenseError = null;
        _professionalTitleError = null;
      });
      return _displayNameError == null;
    }
    if (widget.section == ProfessionalProfileSection.professional) {
      setState(() {
        _displayNameError = null;
        _licenseError = ProfessionalProfileValidators.requiredLine(_license.text);
        _professionalTitleError = ProfessionalProfileValidators.requiredLine(
          _professionalTitle.text,
          emptyMessage: 'শিরোনাম পূরণ করুন',
        );
      });
      return _licenseError == null && _professionalTitleError == null;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final draftAsync = watchProfessionalDraft(ref, widget.persona);

    draftAsync.whenData((session) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _seed(session.draft);
      });
    });

    final title = widget.section.titleBn;

    return PraniScaffold(
      title: title,
      subtitle: widget.persona.labelBn,
      appBarActions: [
        TextButton(
          onPressed: () {
            if (!_validateHard()) return;
            _commitFull();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ড্রাফট যাচাই ও সংরক্ষণ ট্রিগার হয়েছে')),
            );
            context.pop();
          },
          child: const Text('সম্পন্ন'),
        ),
      ],
      body: draftAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('$e')),
        data: (session) {
          final d = session.draft;
          final persistErr = session.persistError;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                PraniSpacing.pageHorizontal,
                PraniSpacing.lg,
                PraniSpacing.pageHorizontal,
                PraniSpacing.xxl,
              ),
              children: [
                if (persistErr != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: PraniSpacing.md),
                    child: Text(
                      persistErr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ..._buildFields(context, d),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context, ProfessionalProfileDraft d) {
    final p = widget.persona;
    final s = widget.section;

    void textCommit() {
      _commitFull();
    }

    switch (s) {
      case ProfessionalProfileSection.basic:
        return [
          PraniProfessionalValidatedField(
            controller: _displayName,
            label: 'প্রদর্শন নাম',
            hint: 'প্ল্যাটফর্মে দেখানো হবে',
            errorText: _displayNameError,
            onChanged: (_) => textCommit(),
          ),
          const SizedBox(height: PraniSpacing.lg),
          PraniProfessionalValidatedField(
            controller: _publicBio,
            label: 'সংক্ষিপ্ত পরিচিতি',
            hint: 'কমপক্ষে ২০ অক্ষর লিখুন',
            maxLines: 4,
            onChanged: (_) => textCommit(),
          ),
        ];
      case ProfessionalProfileSection.professional:
        return [
          PraniProfessionalValidatedField(
            controller: _professionalTitle,
            label: 'পেশাগত শিরোনাম',
            hint: 'যেমন: প্রাণী প্রজনন বিশেষজ্ঞ',
            errorText: _professionalTitleError,
            onChanged: (_) => textCommit(),
          ),
          const SizedBox(height: PraniSpacing.lg),
          PraniProfessionalValidatedField(
            controller: _license,
            label: 'লাইসেন্স / নিবন্ধন নম্বর',
            errorText: _licenseError,
            onChanged: (_) => textCommit(),
          ),
          if (p == ProfessionalPersona.aiTechnician) ...[
            const SizedBox(height: PraniSpacing.lg),
            PraniProfessionalValidatedField(
              controller: _providerCode,
              label: 'প্রদানকারী কোড (ঐচ্ছিক)',
              onChanged: (_) => textCommit(),
            ),
            const SizedBox(height: PraniSpacing.md),
            PraniSecondaryButton(
              label: 'সম্পূর্ণ এআই টেকনিশিয়ান আবেদন ফরম',
              fullWidth: true,
              onPressed: () =>
                  context.push(AiTechnicianApplicationFormScreen.routePath),
            ),
          ],
        ];
      case ProfessionalProfileSection.serviceAreas:
        return [
          PraniProfessionalValidatedField(
            controller: _serviceAreas,
            label: 'সেবা এলাকা (কমা দিয়ে)',
            hint: 'যেমন: নোয়াখালী, ফেনী',
            maxLines: 3,
            onChanged: (_) => textCommit(),
          ),
        ];
      case ProfessionalProfileSection.availability:
        return [
          PraniProfessionalValidatedField(
            controller: _availability,
            label: 'উপলব্ধতা নোট',
            hint: 'সপ্তাহের দিন, সময়, জরুরি গ্রহণ ইত্যাদি',
            maxLines: 5,
            onChanged: (_) => textCommit(),
          ),
        ];
      case ProfessionalProfileSection.experience:
        return [
          PraniProfessionalValidatedField(
            controller: _experience,
            label: 'অভিজ্ঞতা',
            maxLines: 6,
            onChanged: (_) => textCommit(),
          ),
        ];
      case ProfessionalProfileSection.education:
        return [
          PraniProfessionalValidatedField(
            controller: _education,
            label: 'শিক্ষা ও প্রশিক্ষণ',
            maxLines: 6,
            onChanged: (_) => textCommit(),
          ),
        ];
      case ProfessionalProfileSection.pricing:
        return [
          PraniProfessionalValidatedField(
            controller: _pricing,
            label: 'মূল্য ও প্যাকেজ নোট',
            maxLines: 5,
            onChanged: (_) => textCommit(),
          ),
        ];
      case ProfessionalProfileSection.documents:
        return [
          ProfessionalProfileImageSlotCard(
            title: 'প্রোফাইল ছবি',
            subtitle: 'ক্রপ ও কমপ্রেস — তারপর আপলোড',
            persona: p,
            slotKind: ProfessionalProfileImageSlotKind.profilePhoto,
            localPath: d.profilePhotoLocalPath,
            uploadedFileId: d.profilePhotoUploadId,
            onLocalPathChanged: (path) {
              updateProfessionalDraft(ref, p, (x) => x.copyWith(profilePhotoLocalPath: path));
            },
            onUploadedFileIdChanged: (id) {
              updateProfessionalDraft(
                ref,
                p,
                (x) => x.copyWith(profilePhotoUploadId: id),
              );
            },
          ),
          const SizedBox(height: PraniSpacing.md),
          ProfessionalProfileImageSlotCard(
            title: 'সার্টিফিকেট',
            subtitle: 'প্রশিক্ষণ বা বিশেষ সার্টিফিকেট',
            persona: p,
            slotKind: ProfessionalProfileImageSlotKind.certificate,
            localPath: d.certificateLocalPath,
            uploadedFileId: d.certificateUploadId,
            onLocalPathChanged: (path) {
              updateProfessionalDraft(ref, p, (x) => x.copyWith(certificateLocalPath: path));
            },
            onUploadedFileIdChanged: (id) {
              updateProfessionalDraft(
                ref,
                p,
                (x) => x.copyWith(certificateUploadId: id),
              );
            },
          ),
          const SizedBox(height: PraniSpacing.md),
          ProfessionalProfileImageSlotCard(
            title: 'পরিচয়পত্র (সামনের দিক)',
            subtitle: 'জাতীয় পরিচয়পত্র বা সমতুল্য',
            persona: p,
            slotKind: ProfessionalProfileImageSlotKind.identity,
            localPath: d.identityLocalPath,
            uploadedFileId: d.identityUploadId,
            onLocalPathChanged: (path) {
              updateProfessionalDraft(ref, p, (x) => x.copyWith(identityLocalPath: path));
            },
            onUploadedFileIdChanged: (id) {
              updateProfessionalDraft(
                ref,
                p,
                (x) => x.copyWith(identityUploadId: id),
              );
            },
          ),
        ];
      case ProfessionalProfileSection.mediaGallery:
        return [
          ProfessionalProfileImageSlotCard(
            title: 'কাজের নমুনা ছবি',
            subtitle: 'একটি প্রতিনিধিত্বমূলক ছবি (আরও স্লট API-তে)',
            persona: p,
            slotKind: ProfessionalProfileImageSlotKind.workSample,
            localPath: d.workGalleryLocalPaths.isNotEmpty ? d.workGalleryLocalPaths.first : null,
            uploadedFileId:
                d.workGalleryUploadIds.isNotEmpty ? d.workGalleryUploadIds.first : null,
            onLocalPathChanged: (path) {
              updateProfessionalDraft(
                ref,
                p,
                (x) => x.copyWith(
                  workGalleryLocalPaths:
                      path == null ? <String>[] : <String>[path],
                ),
              );
            },
            onUploadedFileIdChanged: (id) {
              updateProfessionalDraft(
                ref,
                p,
                (x) => x.copyWith(
                  workGalleryUploadIds: id == null ? <String>[] : <String>[id],
                ),
              );
            },
          ),
          const SizedBox(height: PraniSpacing.md),
          ProfessionalProfileVideoSlotCard(
            localPath: d.introVideoLocalPath,
            onLocalPathChanged: (path) {
              updateProfessionalDraft(
                ref,
                p,
                (x) => x.copyWith(introVideoLocalPath: path),
              );
            },
          ),
        ];
      case ProfessionalProfileSection.verification:
        return [ProfessionalVerificationWorkflowPanel(persona: p)];
    }
  }
}

