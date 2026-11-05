import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/design_system/widgets/prani_scaffold.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/ai_technician_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/ai_technician_application/data/service_instance_repository.dart';

class AiServiceInstanceDetailScreen extends ConsumerStatefulWidget {
  const AiServiceInstanceDetailScreen({super.key, required this.instanceId});

  final String instanceId;

  static const routePath = '/profile/ai-technician/service-instances';

  @override
  ConsumerState<AiServiceInstanceDetailScreen> createState() =>
      _AiServiceInstanceDetailScreenState();
}

class _AiServiceInstanceDetailScreenState extends ConsumerState<AiServiceInstanceDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  final _payloadCtrl = TextEditingController();

  @override
  void dispose() {
    _payloadCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(serviceInstanceRepositoryProvider);
      final d = await repo.detail(widget.instanceId);
      setState(() {
        _data = d;
        final inst = d['instance'] as Map<String, dynamic>?;
        final pj = inst?['payloadJson'];
        _payloadCtrl.text = const JsonEncoder.withIndent('  ').convert(pj ?? {});
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

  Future<void> _savePayload() async {
    try {
      final parsed = jsonDecode(_payloadCtrl.text);
      if (parsed is! Map<String, dynamic>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পেলোড অবজেক্ট হতে হবে')),
        );
        return;
      }
      final inst = _data?['instance'] as Map<String, dynamic>?;
      final v = (inst?['version'] as num?)?.toInt();
      await ref.read(serviceInstanceRepositoryProvider).update(
            widget.instanceId,
            payload: parsed,
            expectedVersion: v,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সংরক্ষিত')),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    try {
      await ref.read(serviceInstanceRepositoryProvider).submit(widget.instanceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('জমা হয়েছে')),
        );
        await _load();
      }
    } on AiTechnicianApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inst = _data?['instance'] as Map<String, dynamic>?;
    final status = inst?['status'] as String? ?? '';
    final editable = status == 'DRAFT' || status == 'NEEDS_CORRECTION';

    return PraniScaffold(
      title: 'সেবা ইনস্ট্যান্স',
      appBarActions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(PraniSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('অবস্থা: $status', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: PraniSpacing.md),
                      if (editable) ...[
                        TextField(
                          controller: _payloadCtrl,
                          maxLines: 14,
                          decoration: const InputDecoration(
                            labelText: 'payloadJson',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.md),
                        FilledButton(
                          onPressed: _savePayload,
                          child: const Text('সংরক্ষণ'),
                        ),
                        const SizedBox(height: PraniSpacing.sm),
                        FilledButton.tonal(
                          onPressed: _submit,
                          child: const Text('জমা দিন'),
                        ),
                      ] else
                        SelectableText(
                          const JsonEncoder.withIndent('  ').convert(inst ?? {}),
                        ),
                      const SizedBox(height: PraniSpacing.lg),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('ফিরে যান'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
