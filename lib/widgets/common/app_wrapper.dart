import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_banner.dart';

/// Wrapper widget that adds the offline banner to all screens.
/// This should wrap the MaterialApp.router or the router's builder.
class AppWrapper extends ConsumerWidget {
  final Widget child;

  const AppWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Main content
        child,
        // Offline banner at the top - positioned absolutely
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: const OfflineBanner(),
          ),
        ),
      ],
    );
  }
}

