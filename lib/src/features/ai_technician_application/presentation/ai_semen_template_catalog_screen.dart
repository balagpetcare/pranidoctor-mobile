import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_loading_state.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_premium_card.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/semen_template_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_semen_template_detail_screen.dart';

class AiSemenTemplateCatalogScreen extends ConsumerStatefulWidget {
  const AiSemenTemplateCatalogScreen({super.key});

  static const routePath = '/profile/ai-technician/semen-templates';
  static const routeName = 'aiSemenTemplateCatalog';

  @override
  ConsumerState<AiSemenTemplateCatalogScreen> createState() =>
      _AiSemenTemplateCatalogScreenState();
}

class _AiSemenTemplateCatalogScreenState
    extends ConsumerState<AiSemenTemplateCatalogScreen> {
  bool _loading = true;
  String? _error;
  List<SemenTemplateCatalogRow> _rows = [];

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
      final r = await ref.read(aiTechnicianRepositoryProvider).listSemenTemplates();
      if (!mounted) return;
      setState(() {
        _rows = r.templates;
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
    return PraniScaffold(
      title: 'টেমপ্লেট ক্যাটালগ',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: PraniLoadingState(
                      message: 'লোড হচ্ছে…',
                      compact: false,
                    ),
                  ),
                ],
              )
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 48),
                      Center(child: Text(_error!)),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _rows.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: PraniSpacing.sm),
                    itemBuilder: (context, i) {
                      final t = _rows[i];
                      return PraniPremiumCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.internalName),
                          subtitle: Text(
                            '${t.semenProvider.name} · ${t.breedSummaryBn}\n৳${t.defaultBasePrice}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '${AiSemenTemplateDetailScreen.routePath}/${t.id}',
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
