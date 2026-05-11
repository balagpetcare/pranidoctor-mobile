import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pranidoctor_mobile/src/features/professional_profile/data/professional_profile_draft.dart';
import 'package:pranidoctor_mobile/src/features/professional_profile/domain/professional_persona.dart';

class ProfessionalProfileDraftSession {
  const ProfessionalProfileDraftSession({
    required this.draft,
    this.lastSavedAt,
    this.persistError,
  });

  final ProfessionalProfileDraft draft;
  final DateTime? lastSavedAt;
  final String? persistError;

  ProfessionalProfileDraftSession copyWith({
    ProfessionalProfileDraft? draft,
    DateTime? lastSavedAt,
    String? persistError,
    bool clearPersistError = false,
  }) {
    return ProfessionalProfileDraftSession(
      draft: draft ?? this.draft,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      persistError: clearPersistError ? null : (persistError ?? this.persistError),
    );
  }
}

String professionalProfileDraftPrefsKey(ProfessionalPersona persona) =>
    'pd_professional_profile_draft_v2_${persona.name}';

Future<ProfessionalProfileDraft> loadProfessionalDraft(
  ProfessionalPersona persona,
) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(professionalProfileDraftPrefsKey(persona));
  if (raw == null || raw.trim().isEmpty) return const ProfessionalProfileDraft();
  try {
    final map = jsonDecode(raw);
    if (map is! Map<String, dynamic>) return const ProfessionalProfileDraft();
    return ProfessionalProfileDraft.fromJson(map);
  } catch (_) {
    return const ProfessionalProfileDraft();
  }
}

Future<void> persistProfessionalDraft(
  ProfessionalPersona persona,
  ProfessionalProfileDraft draft,
) async {
  final prefs = await SharedPreferences.getInstance();
  final key = professionalProfileDraftPrefsKey(persona);
  await prefs.setString(key, jsonEncode(draft.toJson()));
}

mixin _ProfessionalDraftAutosave on AsyncNotifier<ProfessionalProfileDraftSession> {
  ProfessionalPersona get persona;

  Timer? _autosaveTimer;

  void cancelAutosave() => _autosaveTimer?.cancel();

  void patchDraft(ProfessionalProfileDraft Function(ProfessionalProfileDraft) fn) {
    final cur = switch (state) {
      AsyncData<ProfessionalProfileDraftSession>(:final value) => value,
      _ => null,
    };
    if (cur == null) return;
    state = AsyncData(cur.copyWith(draft: fn(cur.draft), clearPersistError: true));
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 900), () async {
      final snap = switch (state) {
        AsyncData<ProfessionalProfileDraftSession>(:final value) => value,
        _ => null,
      };
      if (snap == null) return;
      try {
        await persistProfessionalDraft(persona, snap.draft);
        if (!ref.mounted) return;
        state = AsyncData(
          snap.copyWith(
            lastSavedAt: DateTime.now(),
            clearPersistError: true,
          ),
        );
      } catch (e) {
        if (!ref.mounted) return;
        state = AsyncData(
          snap.copyWith(
            persistError: 'সংরক্ষণ করা যায়নি (${e.runtimeType})',
          ),
        );
      }
    });
  }

  Future<void> reloadFromDisk() async {
    state = const AsyncLoading();
    state = AsyncData(
      ProfessionalProfileDraftSession(
        draft: await loadProfessionalDraft(persona),
      ),
    );
  }
}

class AiTechnicianProfessionalDraftNotifier
    extends AsyncNotifier<ProfessionalProfileDraftSession>
    with _ProfessionalDraftAutosave {
  @override
  ProfessionalPersona get persona => ProfessionalPersona.aiTechnician;

  @override
  Future<ProfessionalProfileDraftSession> build() async {
    ref.onDispose(cancelAutosave);
    final d = await loadProfessionalDraft(persona);
    return ProfessionalProfileDraftSession(draft: d);
  }

  void applyDraft(ProfessionalProfileDraft Function(ProfessionalProfileDraft) fn) =>
      patchDraft(fn);

  Future<void> refresh() => reloadFromDisk();
}

class VeterinaryDoctorProfessionalDraftNotifier
    extends AsyncNotifier<ProfessionalProfileDraftSession>
    with _ProfessionalDraftAutosave {
  @override
  ProfessionalPersona get persona => ProfessionalPersona.veterinaryDoctor;

  @override
  Future<ProfessionalProfileDraftSession> build() async {
    ref.onDispose(cancelAutosave);
    final d = await loadProfessionalDraft(persona);
    return ProfessionalProfileDraftSession(draft: d);
  }

  void applyDraft(ProfessionalProfileDraft Function(ProfessionalProfileDraft) fn) =>
      patchDraft(fn);

  Future<void> refresh() => reloadFromDisk();
}

final aiTechnicianProfessionalDraftProvider = AsyncNotifierProvider<
    AiTechnicianProfessionalDraftNotifier,
    ProfessionalProfileDraftSession>(
  AiTechnicianProfessionalDraftNotifier.new,
);

final veterinaryDoctorProfessionalDraftProvider = AsyncNotifierProvider<
    VeterinaryDoctorProfessionalDraftNotifier,
    ProfessionalProfileDraftSession>(
  VeterinaryDoctorProfessionalDraftNotifier.new,
);

AsyncValue<ProfessionalProfileDraftSession> watchProfessionalDraft(
  WidgetRef ref,
  ProfessionalPersona persona,
) {
  return switch (persona) {
    ProfessionalPersona.aiTechnician =>
      ref.watch(aiTechnicianProfessionalDraftProvider),
    ProfessionalPersona.veterinaryDoctor =>
      ref.watch(veterinaryDoctorProfessionalDraftProvider),
  };
}

void updateProfessionalDraft(
  WidgetRef ref,
  ProfessionalPersona persona,
  ProfessionalProfileDraft Function(ProfessionalProfileDraft) fn,
) {
  switch (persona) {
    case ProfessionalPersona.aiTechnician:
      ref.read(aiTechnicianProfessionalDraftProvider.notifier).applyDraft(fn);
      break;
    case ProfessionalPersona.veterinaryDoctor:
      ref.read(veterinaryDoctorProfessionalDraftProvider.notifier).applyDraft(fn);
      break;
  }
}
