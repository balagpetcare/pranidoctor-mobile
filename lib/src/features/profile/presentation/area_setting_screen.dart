import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

class AreaSettingScreen extends ConsumerStatefulWidget {
  const AreaSettingScreen({super.key});

  static const routePath = '/profile/area';
  static const routeName = 'profileArea';

  @override
  ConsumerState<AreaSettingScreen> createState() => _AreaSettingScreenState();
}

class _AreaSettingScreenState extends ConsumerState<AreaSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _area;
  bool _loadingUser = true;
  String? _loadError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _area = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final user = await ref.read(mobileUserProvider.future);
      if (!mounted) return;
      setState(() {
        _area.text = user.area ?? '';
        _loadingUser = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingUser = false;
        _loadError = e is ProfileApiException
            ? e.message
            : 'ডেটা লোড করা যায়নি।';
      });
    }
  }

  @override
  void dispose() {
    _area.dispose();
    super.dispose();
  }

  String? _validateArea(String? v) {
    final t = (v ?? '').trim();
    if (t.length < 2) {
      return 'এলাকা বা ঠিকানা কমপক্ষে ২ অক্ষর দিন।';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .patchMe(MobileUserPatch(area: _area.text.trim()));
      ref.invalidate(mobileUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('এলাকা সংরক্ষিত হয়েছে।')));
      context.pop();
    } on ProfileApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('সংরক্ষণ ব্যর্থ হয়েছে। আবার চেষ্টা করুন।'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('এলাকা / ঠিকানা')),
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: pad,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loadingUser = true;
                          _loadError = null;
                        });
                        _load();
                      },
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: pad.copyWith(top: 16, bottom: 28),
              children: [
                Text(
                  'আপনার এলাকা বা ঠিকানার সংক্ষিপ্ত বিবরণ লিখুন। বিভাগ/জেলা নির্বাচনের সিস্টেম পরে যুক্ত হতে পারে।',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _area,
                    decoration: const InputDecoration(
                      labelText: 'এলাকা / ঠিকানা',
                      hintText: 'যেমন: ঢাকা, মিরপুর ১০',
                    ),
                    maxLines: 3,
                    minLines: 2,
                    validator: _validateArea,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('সংরক্ষণ করুন'),
                ),
              ],
            ),
    );
  }
}
