import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

/// Provider for the StorageService instance.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

