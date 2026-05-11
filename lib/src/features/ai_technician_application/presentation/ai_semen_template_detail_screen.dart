import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';

class AiSemenTemplateDetailScreen extends ConsumerStatefulWidget {
  const AiSemenTemplateDetailScreen({super.key, required this.templateId});

  final String templateId;

  static const routePath = '/profile/ai-technician/semen-templates';

  @override
  ConsumerState<AiSemenTemplateDetailScreen> createState() =>
      _AiSemenTemplateDetailScreenState();
}

class _AiSemenTemplateDetailScreenState
    extends ConsumerState<AiSemenTemplateDetailScreen> {
  bool _loading = true;
  String? _error;
  SemenTemplateCatalogRow? _t;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final t = _t;
    return PraniScaffold(
      title: 'টেমপ্লেট বিস্তারিত',
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: PraniSpacing.sm),
                    Text('প্রদানকারী: ${t.semenProvider.name}'),
                    Text('জাত: ${t.breedSummaryBn}'),
                    if (t.shortDescription?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: PraniSpacing.md),
                      Text(t.shortDescription!),
                    ],
                    if (t.warningsContraindications?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: PraniSpacing.md),
                      Text(
                        'সতর্কতা: ${t.warningsContraindications}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: PraniSpacing.lg),
                    PraniPrimaryButton(
                      label: 'এই টেমপ্লেটে সার্ভিস তৈরি',
                      onPressed: () => context.push(
                        '${AiSemenTemplateDetailScreen.routePath}/${t.id}/confirm',
                      ),
                    ),
                  ],
                ),
    );
  }
}
