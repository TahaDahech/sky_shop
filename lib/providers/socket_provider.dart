import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/mock_socket_service.dart';

/// Riverpod provider exposing the [MockSocketService].
///
/// Later, you can switch this to provide a real [SocketService] implementation
/// without touching the UI code.
final mockSocketServiceProvider = Provider<MockSocketService>((ref) {
  final service = MockSocketService();
  ref.onDispose(service.dispose);
  return service;
});


