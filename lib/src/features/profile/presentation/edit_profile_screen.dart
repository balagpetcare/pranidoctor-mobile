import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  static const routePath = '/profile/edit';
  static const routeName = 'profileEdit';

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  String _phone = '—';
  bool _loadingUser = true;
  String? _loadError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final user = await ref.read(mobileUserProvider.future);
      if (!mounted) return;
      setState(() {
        _name.text = user.name;
        _email.text = user.email ?? '';
        _phone = user.phone;
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
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final t = (v ?? '').trim();
    if (t.length < 2) {
      return 'নাম কমপক্ষে ২ অক্ষর দিন।';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
    if (!ok) return 'সঠিক ইমেইল দিন বা খালি রাখুন।';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final emailTrim = _email.text.trim();
      await ref
          .read(profileRepositoryProvider)
          .patchMe(MobileUserPatch(name: _name.text.trim(), email: emailTrim));
      ref.invalidate(mobileUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('সংরক্ষিত হয়েছে।')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল সম্পাদনা')),
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
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'নাম',
                          hintText: 'আপনার নাম',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'ইমেইল (ঐচ্ছিক)',
                          hintText: 'যেমন: নাম@ডোমেইন.কম',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'মোবাইল',
                          helperText: 'মোবাইল নম্বর এখন পরিবর্তন করা যাবে না।',
                        ),
                        child: Text(
                          _phone,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
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
