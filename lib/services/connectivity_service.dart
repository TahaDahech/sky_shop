import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  ConnectivityService() {
    _connectivityController = StreamController<bool>.broadcast();
    _init();
  }

  /// Initialize connectivity monitoring.
  Future<void> _init() async {
    // Check initial connectivity status
    final result = await _connectivity.checkConnectivity();
    _isConnected = result.any((r) => r != ConnectivityResult.none);
    _connectivityController?.add(_isConnected);

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasConnected = _isConnected;
        _isConnected = results.any((r) => r != ConnectivityResult.none);
        
        // Only notify if status changed
        if (wasConnected != _isConnected) {
          _connectivityController?.add(_isConnected);
        }
      },
    );
  }

  /// Stream of connectivity status (true = connected, false = offline).
  Stream<bool> get connectivityStream => _connectivityController!.stream;

  /// Current connectivity status.
  bool get isConnected => _isConnected;

  /// Check current connectivity status.
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result.any((r) => r != ConnectivityResult.none);
    return _isConnected;
  }

  /// Dispose resources.
  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
  }
}

