import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/provider_detail_screen.dart';

/// AI technician profile route target (same UI as [ProviderDetailScreen]).
class TechnicianDetailScreen extends ProviderDetailScreen {
  const TechnicianDetailScreen({super.key, required String technicianId})
    : super(providerId: technicianId, kind: ProviderKind.aiTechnician);

  static const routeName = 'technicianDetail';

  static String pathFor(String id) => '/providers/technicians/$id';
}
