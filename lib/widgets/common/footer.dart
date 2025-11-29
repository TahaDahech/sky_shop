import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constants.dart';

/// A reusable footer widget with logo, links, and social media icons
class Footer extends StatelessWidget {
  const Footer({super.key});

  /// Creates a Sliver widget that ensures the footer extends to the bottom
  /// of the screen if content is shorter than the viewport
  static Widget sliver({Key? key}) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Footer(key: key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 600;

    return Container(
      key: const Key('footer'),
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main footer content
            isMobile
                ? _buildMobileLayout(context, isSmallMobile)
                : _buildDesktopLayout(context),
            const SizedBox(height: 48),
            Divider(color: Colors.grey[800]),
            const SizedBox(height: 24),
            // Copyright and social icons
            isMobile
                ? _buildMobileFooter(context)
                : _buildDesktopFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A9FCC), Color(0xFF5BB7E0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/sky.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.appName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Shopping en direct, moderne et sécurisé.\nDécouvrez une nouvelle façon de faire vos achats.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
        // Footer columns
        Expanded(
          flex: 3,
          child: Wrap(
            spacing: 48,
            runSpacing: 32,
            children: [
              _FooterColumn(
                title: 'Entreprise',
                links: ['À propos', 'Blog', 'Carrières', 'Presse'],
              ),
              _FooterColumn(
                title: 'Support',
                links: ['Centre d\'aide', 'Contact', 'FAQ', 'Statut'],
              ),
              _FooterColumn(
                title: 'Légal',
                links: ['Confidentialité', 'Conditions', 'Cookies'],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isSmallMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        InkWell(
          onTap: () => context.go('/'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: isSmallMobile ? 36 : 40,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A9FCC), Color(0xFF5BB7E0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/sky.svg',
                  width: isSmallMobile ? 20 : 24,
                  height: isSmallMobile ? 20 : 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                if (!isSmallMobile) ...[
                  SizedBox(width: isSmallMobile ? 6 : 8),
                  Text(
                    AppConstants.appName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallMobile ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: isSmallMobile ? 0.8 : 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Shopping en direct, moderne et sécurisé.\nDécouvrez une nouvelle façon de faire vos achats.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        // Footer columns - stacked on mobile
        _FooterColumn(
          title: 'Entreprise',
          links: ['À propos', 'Blog', 'Carrières', 'Presse'],
        ),
        const SizedBox(height: 24),
        _FooterColumn(
          title: 'Support',
          links: ['Centre d\'aide', 'Contact', 'FAQ', 'Statut'],
        ),
        const SizedBox(height: 24),
        _FooterColumn(
          title: 'Légal',
          links: ['Confidentialité', 'Conditions', 'Cookies'],
        ),
      ],
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '© ${DateTime.now().year} ${AppConstants.appName}. Tous droits réservés.',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.facebook),
              onPressed: () {},
              color: Colors.grey[500],
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () {},
              color: Colors.grey[500],
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.tiktok),
              onPressed: () {},
              color: Colors.grey[500],
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '© ${DateTime.now().year} ${AppConstants.appName}. Tous droits réservés.',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.facebook),
              onPressed: () {},
              color: Colors.grey[500],
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () {},
              color: Colors.grey[500],
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tiktok),
              onPressed: () {},
              color: Colors.grey[500],
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(4),
                child: Text(
                  link,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

