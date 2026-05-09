import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pranidoctor_mobile/src/app/screen_padding.dart';
import 'package:pranidoctor_mobile/src/design_system/prani_tokens.dart';
import 'package:pranidoctor_mobile/src/features/profile/application/profile_providers.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/mobile_user_model.dart';
import 'package:pranidoctor_mobile/src/features/profile/data/profile_api_exception.dart';

/// Customer profile edit — `PATCH /api/mobile/me` (`name`, `email`, `area`).
/// Profile photo & OTP phone change are TODO / not supported on this endpoint.
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
  late final TextEditingController _area;

  String _initialName = '';
  String _initialEmail = '';
  String _initialArea = '';
  String _phoneDisplay = '—';
  String? _profilePhotoUrl;

  bool _loadingUser = true;
  String? _loadError;
  bool _saving = false;

  void _markDirty() {
    if (mounted) setState(() {});
  }

  bool get _hasChanges {
    return _name.text.trim() != _initialName.trim() ||
        _email.text.trim() != _initialEmail.trim() ||
        _area.text.trim() != _initialArea.trim();
  }

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
    _area = TextEditingController();
    _name.addListener(_markDirty);
    _email.addListener(_markDirty);
    _area.addListener(_markDirty);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final user = await ref.read(mobileUserProvider.future);
      if (!mounted) return;

      final email = user.email ?? '';
      final areaRaw = user.area?.trim() ?? '';
      final area =
          areaRaw.isEmpty ||
              areaRaw == MobileUser.kPlaceholderAreaBn ||
              areaRaw == 'এলাকা সেট করা হয়নি'
          ? ''
          : areaRaw;

      setState(() {
        _name.text = user.name;
        _email.text = email;
        _area.text = area;
        _initialName = user.name;
        _initialEmail = email;
        _initialArea = area;
        _phoneDisplay = user.phone;
        _profilePhotoUrl = user.profilePhotoUrl;
        _loadingUser = false;
        _loadError = null;
      });
    } catch (e, st) {
      assert(() {
        debugPrint('EditProfileScreen._load failed: $e\n$st');
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
    _area.removeListener(_markDirty);
    _name.dispose();
    _email.dispose();
    _area.dispose();
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

  String? _validateArea(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    if (t.length < 2) return 'এলাকা কমপক্ষে ২ অক্ষর দিন।';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final patch = MobileUserPatch.onlyChangedFields(
      initialName: _initialName,
      initialEmail: _initialEmail,
      initialArea: _initialArea,
      draftName: _name.text,
      draftEmail: _email.text,
      draftArea: _area.text,
    );

    if (patch.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('কোনো পরিবর্তন নেই।')));
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).patchMe(patch);
      ref.invalidate(mobileUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: const Text('পরিবর্তন সংরক্ষিত হয়েছে।'),
        ),
      );
      context.pop();
    } on ProfileApiException catch (e, st) {
      assert(() {
        debugPrint('EditProfileScreen PATCH ProfileApiException: $e\n$st');
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
        debugPrint('EditProfileScreen PATCH unknown: $e\n$st');
        return true;
      }());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            content: Text('পরিবর্তন সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _surfaceSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PraniRadii.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PraniSpacing.xl,
          PraniSpacing.md,
          PraniSpacing.xl,
          PraniSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: PraniSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = pdScreenPadding(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                    const SizedBox(height: PraniSpacing.xl),
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
          : Form(
              key: _formKey,
              child: ListView(
                padding: pad.copyWith(top: PraniSpacing.md, bottom: 32),
                children: [
                  _surfaceSection(
                    context: context,
                    title: 'প্রোফাইল ছবি',
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: scheme.primaryContainer.withValues(
                            alpha: 0.65,
                          ),
                          foregroundImage: _photoProvider(),
                          child: _photoProvider() == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 52,
                                  color: scheme.primary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            // TODO(prani): POST multipart avatar when API ships.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'প্রোফাইল ছবি আপলোড শীঘ্রই আসছে। এখন শুধু নাম/ইমেইল/এলাকা সংরক্ষণ করা যায়।',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('ছবি পরিবর্তন করুন'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  _surfaceSection(
                    context: context,
                    title: 'মৌলিক তথ্য',
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
                      const SizedBox(height: PraniSpacing.md),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'ইমেইল (ঐচ্ছিক)',
                          hintText: 'যেমন: নাম@ডোমেইন.কম',
                          helperText: 'খালি রাখলে আগের ইমেইল অপরিবর্তিত থাকবে।',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                    ],
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  _surfaceSection(
                    context: context,
                    title: 'মোবাইল নম্বর',
                    children: [
                      Text(
                        _phoneDisplay,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      Text(
                        'মোবাইল নম্বর পরিবর্তন করতে OTP যাচাই প্রয়োজন। এখনো এই পাতা থেকে নম্বর পাঠানো হয় না।',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.42,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: PraniSpacing.md),
                  _surfaceSection(
                    context: context,
                    title: 'এলাকা / ঠিকানা',
                    children: [
                      TextFormField(
                        controller: _area,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'এলাকা',
                          hintText: 'উদাহরণ: গাজীপুর, আশুলিয়া',
                          alignLabelWithHint: true,
                        ),
                        validator: _validateArea,
                      ),
                      const SizedBox(height: PraniSpacing.sm),
                      Text(
                        'সংরক্ষণ হবে আপনার প্রোফাইলে। পরিবর্তন না করলে আগের মান থাকবে।',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
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

  ImageProvider<Object>? _photoProvider() {
    final u = _profilePhotoUrl?.trim();
    if (u == null || u.isEmpty) return null;
    if (u.startsWith('http://') || u.startsWith('https://')) {
      return NetworkImage(u);
    }
    return null;
  }
}
