import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/service_instance_models.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/service_instance_repository.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/presentation/ai_semen_template_catalog_screen.dart';

class AiServiceInstancesListScreen extends ConsumerStatefulWidget {
  const AiServiceInstancesListScreen({super.key});

  static const routePath = '/profile/ai-technician/service-instances';
  static const routeName = 'aiServiceInstances';

  @override
  ConsumerState<AiServiceInstancesListScreen> createState() =>
      _AiServiceInstancesListScreenState();
}

class _AiServiceInstancesListScreenState extends ConsumerState<AiServiceInstancesListScreen> {
  List<ServiceInstanceListItem> _items = [];
  String? _next;
  bool _loading = true;
  String? _error;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _next = null;
      _items = [];
    });
    try {
      final repo = ref.read(serviceInstanceRepositoryProvider);
      final page = await repo.list(deploymentBranch: 'main');
      setState(() {
        _items = page.items;
        _next = page.nextCursor;
      });
    } on AiTechnicianApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return PraniScaffold(
      title: 'এন্টারপ্রাইজ সেবা জমা',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AiSemenTemplateCatalogScreen.routePath),
        icon: const Icon(Icons.add),
        label: const Text('টেমপ্লেট থেকে'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(PraniSpacing.lg),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _items.length + (_next != null ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= _items.length) {
                        return TextButton(
                          onPressed: () async {
                            final repo = ref.read(serviceInstanceRepositoryProvider);
                            final page = await repo.list(
                              deploymentBranch: 'main',
                              cursor: _next,
                            );
                            setState(() {
                              _items = [..._items, ...page.items];
                              _next = page.nextCursor;
                            });
                          },
                          child: const Text('আরও'),
                        );
                      }
                      final r = _items[i];
                      return ListTile(
                        title: Text(r.templateName),
                        subtitle: Text('${r.status} · v${r.version}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          '${AiServiceInstancesListScreen.routePath}/${r.id}',
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
