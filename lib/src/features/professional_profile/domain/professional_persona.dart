/// Workspace role for professional profile editing (separate prefs + copy per persona).
enum ProfessionalPersona {
  aiTechnician,
  veterinaryDoctor,
}

/// Parses [ProfessionalProfileHubScreen.routePath] segment (`ai-technician` / `doctor`).
ProfessionalPersona? parseProfessionalPersonaRoute(String? raw) {
  switch (raw?.trim()) {
    case 'ai-technician':
      return ProfessionalPersona.aiTechnician;
    case 'doctor':
      return ProfessionalPersona.veterinaryDoctor;
    default:
      return null;
  }
}

extension ProfessionalPersonaRoute on ProfessionalPersona {
  String get routeSegment => switch (this) {
        ProfessionalPersona.aiTechnician => 'ai-technician',
        ProfessionalPersona.veterinaryDoctor => 'doctor',
      };

  String get labelBn => switch (this) {
        ProfessionalPersona.aiTechnician => 'এআই টেকনিশিয়ান',
        ProfessionalPersona.veterinaryDoctor => 'চিকিৎসক',
      };
}
