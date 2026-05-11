import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstracts connectivity checks for tests and future multi-transport probes.
abstract class ConnectivityPort {
  Future<bool> get isConnected;

  /// Fires whenever the platform reports a connectivity change.
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class ConnectivityPlusPort implements ConnectivityPort {
  ConnectivityPlusPort({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final r = await _connectivity.checkConnectivity();
    return _onlineFromResults(r);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  static bool _onlineFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.any((e) => e != ConnectivityResult.none);
  }
}
