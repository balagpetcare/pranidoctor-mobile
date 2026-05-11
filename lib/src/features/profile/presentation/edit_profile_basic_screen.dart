import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_design_system.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';
import 'package:pranidoctor_mobile/src/features/profile/presentation/widgets/profile_header_card.dart'
    show profileRoleLabelBn;

/// Name + email — [MobileUserRepository.updateBasicProfile] (legacy `PATCH /api/mobile/me`
/// or split `PATCH /api/mobile/me/profile` when enabled in `mobile_profile_api_contract.dart`).
class EditProfileBasicScreen extends ConsumerStatefulWidget {
  const EditProfileBasicScreen({super.key});

  static const routePath = '/profile/edit/basic';
  static const routeName = 'profileEditBasic';

  @override
  ConsumerState<EditProfileBasicScreen> createState() =>
      _EditProfileBasicScreenState();
}

class _EditProfileBasicScreenState
    extends ConsumerState<EditProfileBasicScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;

  String _initialName = '';
  String _initialEmail = '';

  String _roleDisplay = 'customer';
  bool _loadingUser = true;
  String? _loadError;
  bool _saving = false;

  void _markDirty() {
    if (mounted) setState(() {});
  }

  bool get _hasChanges =>
      _name.text.trim() != _initialName.trim() ||
      _email.text.trim() != _initialEmail.trim();

  bool get _emailOk {
    final t = _email.text.trim();
    if (t.isEmpty) return true;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
  }

  bool get _canSave =>
      !_loadingUser &&
      _loadError == null &&
      !_saving &&
      _hasChanges &&
      _name.text.trim().length >= 2 &&
      _emailOk;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _name.addListener(_markDirty);
    _email.addListener(_markDirty);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final user = await ref.read(mobileUserProvider.future);
      if (!mounted) return;

      final email = user.email ?? '';
      setState(() {
        _name.text = user.name;
        _email.text = email;
        _initialName = user.name;
        _initialEmail = email;
        _roleDisplay = user.role ?? 'customer';
        _loadingUser = false;
        _loadError = null;
      });
    } catch (e, st) {
      assert(() {
        debugPrint('EditProfileBasicScreen._load failed: $e\n$st');
        return true;
      }());
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
    _name.removeListener(_markDirty);
    _email.removeListener(_markDirty);
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'নাম লিখুন';
    if (t.length < 2) return 'নাম কমপক্ষে ২ অক্ষর দিন।';
    return null;
  }

  String? _validateEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
    if (!ok) return 'সঠিক ইমেইল দিন';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final draftName = _name.text.trim();
    final draftEmail = _email.text.trim();
    final inName = _initialName.trim();
    final inEmail = _initialEmail.trim();

    String? nameArg;
    if (draftName != inName) nameArg = draftName;

    String? emailArg;
    if (draftEmail != inEmail && draftEmail.isNotEmpty) emailArg = draftEmail;

    if (nameArg == null && emailArg == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('কোনো পরিবর্তন নেই।')));
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateBasicProfile(name: nameArg, email: emailArg);
      ref.invalidate(mobileUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Text('পরিবর্তন সংরক্ষিত হয়েছে।'),
        ),
      );
      context.pop();
    } on ProfileApiException catch (e, st) {
      assert(() {
        debugPrint('EditProfileBasicScreen PATCH: $e\n$st');
        return true;
      }());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            content: Text(e.message),
          ),
        );
      }
    } catch (e, st) {
      assert(() {
        debugPrint('EditProfileBasicScreen PATCH unknown: $e\n$st');
        return true;
      }());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            content: Text('সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'),
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
    final textTheme = Theme.of(context).textTheme;

    return PraniScaffold(
      title: 'মৌলিক তথ্য',
      subtitle: 'নাম ও ইমেইল',
      body: _loadingUser
          ? const Center(
              child: PraniLoadingState(
                message: 'তথ্য লোড হচ্ছে…',
                compact: false,
              ),
            )
          : _loadError != null
          ? Center(
              child: Padding(
                padding: pad,
                child: PraniErrorState(
                  title: 'লোড ব্যর্থ',
                  message: _loadError!,
                  retryLabel: 'আবার চেষ্টা',
                  onRetry: () {
                    setState(() {
                      _loadingUser = true;
                      _loadError = null;
                    });
                    _load();
                  },
                  detail: null,
                  compact: false,
                  boxed: true,
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: pad.copyWith(top: PraniSpacing.md, bottom: 32),
                children: [
                  PraniPremiumCard(
                    padding: const EdgeInsets.all(PraniSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ভূমিকা',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.sm),
                        InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.badge_outlined, color: scheme.primary),
                              const SizedBox(width: PraniSpacing.md),
                              Expanded(
                                child: Text(
                                  profileRoleLabelBn(_roleDisplay),
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.xs),
                        Text(
                          'ভূমিকা সার্ভার থেকে নির্ধারিত; এখানে শুধু দেখানো হয়।',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: PraniSpacing.xl),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'নাম',
                            hintText: 'আপনার নাম',
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: _validateName,
                        ),
                        const SizedBox(height: PraniSpacing.md),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'ইমেইল (ঐচ্ছিক)',
                            hintText: 'যেমন: নাম@ডোমেইন.কম',
                            helperText:
                                'খালি রাখলে আগের ইমেইল অপরিবর্তিত থাকবে।',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PraniSpacing.section),
                  FilledButton(
                    onPressed: _canSave ? _save : null,
                    child: _saving
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const Text('পরিবর্তন সংরক্ষণ করুন'),
                  ),
                ],
              ),
            ),
    );
  }
}
