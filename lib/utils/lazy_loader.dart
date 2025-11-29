import 'package:flutter/material.dart';

/// Helper widget for lazy loading deferred imports
/// Shows a loading indicator while the library is being loaded
class LazyLoader extends StatelessWidget {
  final Future<void> Function() loadLibrary;
  final Widget Function() buildWidget;

  const LazyLoader({
    super.key,
    required this.loadLibrary,
    required this.buildWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadLibrary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return buildWidget();
        }
        // Show loading indicator
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF4A9FCC),
            ),
          ),
        );
      },
    );
  }
}

