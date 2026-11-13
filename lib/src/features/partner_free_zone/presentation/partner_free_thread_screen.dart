import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/partner_shell_scope.dart';
import '../../../app/shell/partner_ui.dart';
import '../data/partner_free_zone_repository.dart';

/// Comment thread of one free question: verified doctors can comment; any comment can be reported.
class PartnerFreeThreadScreen extends ConsumerStatefulWidget {
  const PartnerFreeThreadScreen({super.key, required this.question});
  final FreeFeedItem question;

  @override
  ConsumerState<PartnerFreeThreadScreen> createState() => _PartnerFreeThreadScreenState();
}

class _PartnerFreeThreadScreenState extends ConsumerState<PartnerFreeThreadScreen> {
  final _input = TextEditingController();
  List<FreeThreadComment>? _items;
  String? _error;
  bool _busy = false;

  PartnerFreeZoneRepository get _repo => ref.read(partnerFreeZoneRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final r = await _repo.comments(widget.question.id);
      if (mounted) setState(() => _items = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _repo.postComment(widget.question.id, body);
      _input.clear();
      await _load();
    } catch (e) {
      if (mounted) _toast(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _report(FreeThreadComment c) async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('মন্তব্যটি রিপোর্ট করুন'),
        content: TextField(
          controller: reason,
          maxLength: 300,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'কারণ (ঐচ্ছিক)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('বাতিল')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('রিপোর্ট করুন')),
        ],
      ),
    );
    final text = reason.text;
    reason.dispose();
    if (ok != true) return;
    try {
      await _repo.reportComment(c.id, reason: text);
      await _load();
      if (mounted) _toast('রিপোর্ট পাঠানো হয়েছে। ধন্যবাদ।');
    } catch (e) {
      if (mounted) _toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget list;
    if (_error != null && _items == null) {
      list = PartnerErrorState(message: _error!, onRetry: _load);
    } else if (_items == null) {
      list = const Center(child: CircularProgressIndicator());
    } else if (_items!.isEmpty) {
      list = const Center(child: Text('এখনও কোনো মন্তব্য নেই।'));
    } else {
      list = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items!.length,
        itemBuilder: (context, i) {
          final c = _items![i];
          return Opacity(
            opacity: c.hidden ? 0.55 : 1,
            child: Card(
              child: ListTile(
                title: Row(children: [
                  Flexible(child: Text(c.isMine ? '${c.authorName} (আপনি)' : c.authorName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (c.verified) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified, size: 16, color: Colors.blue)),
                ]),
                subtitle: Text(c.hidden ? '${c.body}\n(লুকানো — অন্যরা দেখছে না)' : c.body),
                isThreeLine: c.hidden,
                trailing: c.canReport
                    ? IconButton(tooltip: 'রিপোর্ট করুন', icon: const Icon(Icons.flag_outlined), onPressed: () => _report(c))
                    : null,
              ),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: partnerScreenAppBar(context, title: 'প্রশ্ন ও মন্তব্য'),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(12),
          child: Text(widget.question.symptoms),
        ),
        Expanded(child: list),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  maxLength: 1000,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'ডাক্তার হিসেবে মন্তব্য (ফোন নম্বর দেওয়া নিষেধ)', counterText: ''),
                ),
              ),
              IconButton(onPressed: _busy ? null : _send, icon: const Icon(Icons.send)),
            ]),
          ),
        ),
      ]),
    );
  }
}
