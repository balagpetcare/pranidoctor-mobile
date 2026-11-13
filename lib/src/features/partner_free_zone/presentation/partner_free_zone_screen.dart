import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/shell/partner_shell_scope.dart';
import '../../../app/shell/partner_ui.dart';
import '../data/partner_free_zone_repository.dart';
import 'partner_free_feed_screen.dart';

/// Doctor-only Free Zone: open free questions, my free slots, my points.
class PartnerFreeZoneScreen extends ConsumerStatefulWidget {
  const PartnerFreeZoneScreen({super.key});

  static const routePath = '/partner/free-zone';
  static const routeName = 'partnerFreeZone';

  @override
  ConsumerState<PartnerFreeZoneScreen> createState() => _PartnerFreeZoneScreenState();
}

class _PartnerFreeZoneScreenState extends ConsumerState<PartnerFreeZoneScreen> {
  List<FreeQuestion>? _queue;
  List<FreeSlot>? _slots;
  Leaderboard? _board;
  List<RewardPeriod> _rewards = const [];
  String _period = 'week';
  int _points = 0;
  String? _error;
  String? _busy;

  @override
  void initState() {
    super.initState();
    _load();
  }

  PartnerFreeZoneRepository get _repo => ref.read(partnerFreeZoneRepositoryProvider);

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final r = await Future.wait([_repo.queue(), _repo.slots(), _repo.points(), _repo.leaderboard(_period), _repo.rewards()]);
      if (!mounted) return;
      setState(() {
        _queue = r[0] as List<FreeQuestion>;
        _slots = r[1] as List<FreeSlot>;
        _points = r[2] as int;
        _board = r[3] as Leaderboard;
        _rewards = r[4] as List<RewardPeriod>;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _claim(FreeQuestion q) async {
    setState(() => _busy = q.id);
    try {
      await _repo.claim(q.id);
      _toast('গ্রহণ করা হয়েছে। "কাজের তালিকা"-য় দেখুন।');
      await _load();
    } catch (e) {
      _toast(e.toString());
      await _load();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _appeal(RewardPeriod p) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('আপিল'),
        content: TextField(controller: c, maxLines: 4, maxLength: 1000, decoration: const InputDecoration(hintText: 'কেন আপিল করছেন লিখুন')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('বাতিল')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('পাঠান')),
        ],
      ),
    );
    final note = c.text;
    c.dispose();
    if (ok != true) return;
    try {
      await _repo.appeal(p.id, note);
      _toast('আপিল পাঠানো হয়েছে');
      await _load();
    } catch (e) {
      _toast(e.toString());
    }
  }

  String _resultBn(RewardPeriod p) {
    if (p.resultRank == null) return 'আপনি এই সময়কালে বিজয়ীদের তালিকায় নেই।';
    final st = switch (p.resultStatus) {
      'AWARDED' => 'প্রদান করা হয়েছে',
      'REVOKED' => 'বাতিল',
      _ => 'অপেক্ষমাণ',
    };
    return 'আপনার অবস্থান: ${p.resultRank} · ${p.resultPrize ?? 'পুরস্কার নেই'} · $st';
  }

  Future<void> _addSlot() async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (day == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (t == null || !mounted) return;
    final start = DateTime(day.year, day.month, day.day, t.hour, t.minute);
    var minutes = 30;
    var mode = 'TEXT';
    var cap = 3;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('ফ্রি স্লট'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<int>(
              initialValue: minutes,
              decoration: const InputDecoration(labelText: 'সময়কাল'),
              items: const [
                DropdownMenuItem(value: 15, child: Text('১৫ মিনিট')),
                DropdownMenuItem(value: 30, child: Text('৩০ মিনিট')),
                DropdownMenuItem(value: 60, child: Text('১ ঘণ্টা')),
              ],
              onChanged: (v) => set(() => minutes = v ?? 30),
            ),
            DropdownButtonFormField<String>(
              initialValue: mode,
              decoration: const InputDecoration(labelText: 'মাধ্যম'),
              items: const [
                DropdownMenuItem(value: 'TEXT', child: Text('টেক্সট')),
                DropdownMenuItem(value: 'AUDIO', child: Text('অডিও')),
                DropdownMenuItem(value: 'VIDEO', child: Text('ভিডিও')),
              ],
              onChanged: (v) => set(() => mode = v ?? 'TEXT'),
            ),
            DropdownButtonFormField<int>(
              initialValue: cap,
              decoration: const InputDecoration(labelText: 'সর্বোচ্চ গ্রাহক'),
              items: [for (final n in [1, 2, 3, 5, 10]) DropdownMenuItem(value: n, child: Text('$n জন'))],
              onChanged: (v) => set(() => cap = v ?? 3),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('বাতিল')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('সংরক্ষণ')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _repo.addSlot(startsAt: start, endsAt: start.add(Duration(minutes: minutes)), capacity: cap, mode: mode);
      await _load();
    } catch (e) {
      _toast(e.toString());
    }
  }

  Future<void> _deleteSlot(FreeSlot s) async {
    try {
      await _repo.deleteSlot(s.id);
      await _load();
    } catch (e) {
      _toast(e.toString());
    }
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final body = _error != null && _queue == null
        ? PartnerErrorState(message: _error!, onRetry: _load)
        : _queue == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.stars_rounded),
                      title: const Text('আমার পয়েন্ট'),
                      trailing: Text('$_points', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.forum_outlined),
                      title: const Text('সবার প্রশ্ন ও মন্তব্য'),
                      subtitle: const Text('প্রশ্নের নিচে মন্তব্য করুন বা অনুপযুক্ত মন্তব্য রিপোর্ট করুন'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(PartnerFreeFeedScreen.routePath),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('খোলা ফ্রি প্রশ্ন', style: Theme.of(context).textTheme.titleMedium),
                  if (_queue!.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('এখন কোনো খোলা প্রশ্ন নেই।')),
                  for (final q in _queue!)
                    Card(
                      child: ListTile(
                        leading: Icon(q.isEmergency ? Icons.warning_amber_rounded : Icons.help_outline,
                            color: q.isEmergency ? Colors.red : null),
                        title: Text('${q.animalName} (${q.animalSpecies})'),
                        subtitle: Text(q.symptoms, maxLines: 3, overflow: TextOverflow.ellipsis),
                        trailing: FilledButton(
                          onPressed: _busy == null ? () => _claim(q) : null,
                          child: Text(_busy == q.id ? '…' : 'গ্রহণ'),
                        ),
                      ),
                    ),
                  if (_rewards.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('পুরস্কার', style: Theme.of(context).textTheme.titleMedium),
                    for (final p in _rewards)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.title, style: Theme.of(context).textTheme.titleSmall),
                            Text(p.closed ? 'ফল প্রকাশিত' : 'চলমান — শেষ ${p.endsAt.day}/${p.endsAt.month}'),
                            if (p.prizes.isNotEmpty) Text(p.prizes.join(' · ')),
                            if (p.closed) Text(_resultBn(p)),
                            if (p.closed && p.appealStatus == null)
                              TextButton(onPressed: () => _appeal(p), child: const Text('আপিল করুন')),
                            if (p.appealStatus != null)
                              Text('আপিল: ${switch (p.appealStatus) {
                                'ACCEPTED' => 'গৃহীত',
                                'REJECTED' => 'প্রত্যাখ্যাত',
                                _ => 'বিবেচনাধীন',
                              }}'),
                          ]),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Text('লিডারবোর্ড', style: Theme.of(context).textTheme.titleMedium)),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'week', label: Text('সাপ্তাহিক')),
                        ButtonSegment(value: 'month', label: Text('মাসিক')),
                      ],
                      selected: {_period},
                      onSelectionChanged: (v) {
                        setState(() => _period = v.first);
                        _load();
                      },
                    ),
                  ]),
                  if (_board != null && _board!.rows.isEmpty)
                    const Padding(padding: EdgeInsets.all(12), child: Text('এই সময়ে এখনো কোনো পয়েন্ট নেই।')),
                  if (_board != null)
                    for (final r in _board!.rows)
                      ListTile(
                        dense: true,
                        selected: r.isMe,
                        leading: CircleAvatar(radius: 14, child: Text('${r.rank}')),
                        title: Row(children: [
                          Flexible(child: Text(r.isMe ? '${r.name} (আপনি)' : r.name)),
                          if (r.verified) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified, size: 16, color: Colors.blue)),
                        ]),
                        trailing: Text('${r.points}'),
                      ),
                  if (_board?.myRank != null && !_board!.rows.any((r) => r.isMe))
                    ListTile(dense: true, title: Text('আপনার অবস্থান: ${_board!.myRank}'), trailing: Text('${_board!.myPoints}')),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Text('আমার ফ্রি স্লট', style: Theme.of(context).textTheme.titleMedium)),
                    TextButton.icon(onPressed: _addSlot, icon: const Icon(Icons.add), label: const Text('নতুন স্লট')),
                  ]),
                  if (_slots!.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('কোনো স্লট নেই।')),
                  for (final s in _slots!)
                    Card(
                      child: ListTile(
                        title: Text('${_fmt(s.startsAt)} – ${_fmt(s.endsAt)}'),
                        subtitle: Text('${s.mode} · বুকড ${s.bookedCount}/${s.capacity}'),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteSlot(s)),
                      ),
                    ),
                ]),
              );
    return Scaffold(appBar: partnerScreenAppBar(context, title: 'ফ্রি জোন'), body: body);
  }
}
