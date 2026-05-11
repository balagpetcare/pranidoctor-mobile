import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_page_insets.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_buttons.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/application/ai_technician_providers.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_models.dart';

class AiTechnicianRequestCompleteScreen extends ConsumerStatefulWidget {
  const AiTechnicianRequestCompleteScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AiTechnicianRequestCompleteScreen> createState() =>
      _AiTechnicianRequestCompleteScreenState();
}

class _AiTechnicianRequestCompleteScreenState
    extends ConsumerState<AiTechnicianRequestCompleteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _heatCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();

  DateTime _serviceAt = DateTime.now();
  DateTime? _inseminAt;
  DateTime? _followUp;
  DateTime? _pregCheck;
  String _animal = AiTechnicianAnimalTypes.values.first;
  String _payment = 'UNPAID';
  bool _submitting = false;

  static const _payments = ['UNPAID', 'DUE', 'CASH_PAID', 'MANUAL_PAID'];

  String _paymentBn(String code) {
    switch (code) {
      case 'UNPAID':
        return 'অপরিশোধিত';
      case 'DUE':
        return 'বাকি';
      case 'CASH_PAID':
        return 'নগদে পরিশোধিত';
      case 'MANUAL_PAID':
        return 'ম্যানুয়ালি পরিশোধিত';
      default:
        return code;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _breedCtrl.dispose();
    _batchCtrl.dispose();
    _heatCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required ValueChanged<DateTime?> onPick,
    DateTime? initial,
  }) async {
    final d0 = initial ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime(d0.year, d0.month, d0.day),
    );
    if (!mounted || d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: d0.hour, minute: d0.minute),
    );
    if (!mounted || t == null) return;
    onPick(DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নিশ্চিত করুন'),
        content: const Text(
          'সম্পন্ন করার পরে এই অনুরোধ আর পরিবর্তন করা যাবে না। চালিয়ে যাবেন?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final feeRaw = _feeCtrl.text.trim();
      final body = <String, dynamic>{
        'serviceDate': _serviceAt.toUtc().toIso8601String(),
        'animalType': _animal,
        'serviceNote': _noteCtrl.text.trim(),
        'paymentStatus': _payment,
        if (_breedCtrl.text.trim().isNotEmpty)
          'breedOrSemenType': _breedCtrl.text.trim(),
        if (_batchCtrl.text.trim().isNotEmpty)
          'semenBatch': _batchCtrl.text.trim(),
        if (_heatCtrl.text.trim().isNotEmpty)
          'heatObservation': _heatCtrl.text.trim(),
        if (_inseminAt != null)
          'inseminationTime': _inseminAt!.toUtc().toIso8601String(),
        if (_followUp != null)
          'nextFollowUpDate': _followUp!.toUtc().toIso8601String(),
        if (_pregCheck != null)
          'pregnancyCheckDate': _pregCheck!.toUtc().toIso8601String(),
        if (feeRaw.isNotEmpty) 'totalFee': feeRaw,
      };
      await ref
          .read(aiTechnicianRepositoryProvider)
          .completeTechnicianJobRequest(widget.requestId, body);
      if (!mounted) return;
      ref.invalidate(aiTechnicianJobRequestDetailProvider(widget.requestId));
      invalidateAiTechnicianJobRequestLists(ref);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('সম্পন্ন হয়েছে।')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final msg = e is AiTechnicianApiException ? e.message : '$e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = PraniPageInsets.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;
    final df = DateFormat('yyyy-MM-dd HH:mm');

    return PraniScaffold(
      title: 'সেবা সম্পন্ন ফর্ম',
      padding: EdgeInsets.fromLTRB(
        hPad,
        PraniSpacing.md,
        hPad,
        PraniSpacing.lg,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('সেবার তারিখ ও সময়'),
              subtitle: Text(df.format(_serviceAt)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _submitting
                  ? null
                  : () => _pickDateTime(
                      initial: _serviceAt,
                      onPick: (v) {
                        if (v != null) setState(() => _serviceAt = v);
                      },
                    ),
            ),
            DropdownButtonFormField<String>(
              value: _animal, // ignore: deprecated_member_use
              decoration: const InputDecoration(labelText: 'প্রাণীর ধরন'),
              items: AiTechnicianAnimalTypes.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(AiTechnicianAnimalTypes.labelBn(e)),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (v) {
                      if (v != null) setState(() => _animal = v);
                    },
            ),
            TextFormField(
              controller: _breedCtrl,
              decoration: const InputDecoration(
                labelText: 'জাত / সিমেনের ধরন (ঐচ্ছিক)',
              ),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _batchCtrl,
              decoration: const InputDecoration(
                labelText: 'সিমেন ব্যাচ / উৎস (ঐচ্ছিক)',
              ),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: _heatCtrl,
              decoration: const InputDecoration(
                labelText: 'হিট পর্যবেক্ষণ (ঐচ্ছিক)',
              ),
              maxLines: 2,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('গর্ভসঞ্চার সময় (ঐচ্ছিক)'),
              subtitle: Text(
                _inseminAt != null ? df.format(_inseminAt!) : 'নির্বাচন করুন',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _submitting
                    ? null
                    : () => setState(() => _inseminAt = null),
              ),
              onTap: _submitting
                  ? null
                  : () => _pickDateTime(
                      initial: _inseminAt,
                      onPick: (v) => setState(() => _inseminAt = v),
                    ),
            ),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'নোট'),
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'নোট প্রয়োজন';
                return null;
              },
            ),
            TextFormField(
              controller: _feeCtrl,
              decoration: const InputDecoration(
                labelText: 'মোট ফি (৳, ঐচ্ছিক)',
              ),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _payment, // ignore: deprecated_member_use
              decoration: const InputDecoration(labelText: 'পরিশোধ অবস্থা'),
              items: _payments
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(_paymentBn(e))),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (v) {
                      if (v != null) setState(() => _payment = v);
                    },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('পরবর্তী ফলোআপ (ঐচ্ছিক)'),
              subtitle: Text(
                _followUp != null ? df.format(_followUp!) : 'নির্বাচন করুন',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _submitting
                    ? null
                    : () => setState(() => _followUp = null),
              ),
              onTap: _submitting
                  ? null
                  : () => _pickDateTime(
                      initial: _followUp,
                      onPick: (v) => setState(() => _followUp = v),
                    ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('গর্ভ পরীক্ষার তারিখ (ঐচ্ছিক)'),
              subtitle: Text(
                _pregCheck != null ? df.format(_pregCheck!) : 'নির্বাচন করুন',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _submitting
                    ? null
                    : () => setState(() => _pregCheck = null),
              ),
              onTap: _submitting
                  ? null
                  : () => _pickDateTime(
                      initial: _pregCheck,
                      onPick: (v) => setState(() => _pregCheck = v),
                    ),
            ),
            const SizedBox(height: PraniSpacing.lg),
            PraniPrimaryButton(
              label: 'সম্পন্ন সংরক্ষণ করুন',
              onPressed: _submitting ? null : _submit,
            ),
            const SizedBox(height: PraniSpacing.sm),
            Text(
              'অনলাইন পেমেন্ট নয় — নগদ/ম্যানুয়াল মেনে নেওয়া হয়।',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
