import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/partner_shell_scope.dart';
import '../../../app/shell/partner_ui.dart';
import '../data/partner_free_zone_repository.dart';
import 'partner_free_thread_screen.dart';

/// Public Q&A feed of free questions. Tap one to read the thread and comment as a verified doctor.
class PartnerFreeFeedScreen extends ConsumerStatefulWidget {
  const PartnerFreeFeedScreen({super.key});

  static const routePath = '/partner/free-zone/feed';
  static const routeName = 'partnerFreeFeed';

  @override
  ConsumerState<PartnerFreeFeedScreen> createState() => _PartnerFreeFeedScreenState();
}

class _PartnerFreeFeedScreenState extends ConsumerState<PartnerFreeFeedScreen> {
  List<FreeFeedItem>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final r = await ref.read(partnerFreeZoneRepositoryProvider).feed();
      if (mounted) setState(() => _items = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final body = _error != null && _items == null
        ? PartnerErrorState(message: _error!, onRetry: _load)
        : _items == null
            ? const Center(child: CircularProgressIndicator())
            : _items!.isEmpty
                ? const Center(child: Text('এখনও কোনো প্রশ্ন নেই।'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items!.length,
                      itemBuilder: (context, i) {
                        final q = _items![i];
                        return Card(
                          child: ListTile(
                            leading: Icon(q.isEmergency ? Icons.warning_amber_rounded : Icons.help_outline,
                                color: q.isEmergency ? Colors.red : null),
                            title: Text(q.symptoms, maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text([if (q.species.isNotEmpty) q.species, _fmt(q.submittedAt)].join(' · ')),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.chat_bubble_outline, size: 18),
                              const SizedBox(width: 4),
                              Text('${q.commentCount}'),
                            ]),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (_) => PartnerFreeThreadScreen(question: q)),
                              );
                              if (mounted) _load();
                            },
                          ),
                        );
                      },
                    ),
                  );
    return Scaffold(appBar: partnerScreenAppBar(context, title: 'সবার ফ্রি প্রশ্ন'), body: body);
  }
}
