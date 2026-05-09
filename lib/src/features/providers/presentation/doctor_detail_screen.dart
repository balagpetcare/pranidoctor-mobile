import 'package:pranidoctor_mobile/src/features/providers/data/provider_kind.dart';
import 'package:pranidoctor_mobile/src/features/providers/presentation/provider_detail_screen.dart';

/// Doctor profile route target (same UI as [ProviderDetailScreen]).
class DoctorDetailScreen extends ProviderDetailScreen {
  const DoctorDetailScreen({super.key, required String doctorId})
    : super(providerId: doctorId, kind: ProviderKind.doctor);

  static const routeName = 'doctorDetail';

  static String pathFor(String id) => '/providers/doctors/$id';
}
