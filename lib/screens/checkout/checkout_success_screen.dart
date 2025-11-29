import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/footer.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Commande confirmée',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          final iconSize = isLargeScreen ? 80.0 : 120.0;
          final iconInnerSize = isLargeScreen ? 40.0 : 64.0;
          final padding = isLargeScreen ? 32.0 : 48.0;
          final titleFontSize = isLargeScreen ? 24.0 : 28.0;
          final subtitleFontSize = isLargeScreen ? 16.0 : 18.0;
          final spacing = isLargeScreen ? 16.0 : 32.0;
          final smallSpacing = isLargeScreen ? 12.0 : 16.0;
          final buttonSpacing = isLargeScreen ? 24.0 : 40.0;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(isLargeScreen ? 16 : 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Success icon with animated circle
                            Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4A9FCC), Color(0xFF5BB7E0)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4A9FCC).withOpacity(0.3),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: iconInnerSize,
                              ),
                            ),
                            SizedBox(height: spacing),
                            Text(
                              'Commande confirmée !',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: smallSpacing),
                            Text(
                              'Merci pour votre achat !',
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacing),
                            Container(
                              padding: EdgeInsets.all(isLargeScreen ? 16 : 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A9FCC).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF4A9FCC).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: const Color(0xFF4A9FCC),
                                    size: isLargeScreen ? 20 : 24,
                                  ),
                                  SizedBox(width: isLargeScreen ? 10 : 12),
                                  Expanded(
                                    child: Text(
                                      'Vous recevrez une confirmation par email avec les détails de votre commande.',
                                      style: TextStyle(
                                        fontSize: isLargeScreen ? 13 : 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: buttonSpacing),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.go('/'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A9FCC),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isLargeScreen ? 14 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: isLargeScreen ? 15 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Retour à l\'accueil'),
                              ),
                            ),
                            SizedBox(height: smallSpacing),
                            TextButton(
                              onPressed: () => context.go('/'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF4A9FCC),
                                padding: EdgeInsets.symmetric(
                                  vertical: isLargeScreen ? 10 : 12,
                                ),
                              ),
                              child: const Text('Voir mes commandes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}


