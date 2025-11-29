import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/live_event.dart';
import '../../providers/category_provider.dart';
import '../../providers/live_event_provider.dart';
import '../../widgets/common/footer.dart';
import '../../widgets/common/optimized_image.dart';
import '../../widgets/common/top_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _liveSectionKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLiveSection() {
    final context = _liveSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  void _scrollToFooter() {
    final context = _footerKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncEvents = ref.watch(liveEventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(liveEventsProvider);
          await ref.read(liveEventsProvider.future);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const TopBar(),
            SliverToBoxAdapter(
              child: _HeroSection(
                onExploreTap: _scrollToLiveSection,
                onLearnMoreTap: _scrollToFooter,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _SearchAndFilters(),
              ),
            ),
            asyncEvents.when(
              data: (events) {
                final live = events.where((e) => e.status == 'live').toList();
                final upcoming = events.where((e) => e.status == 'scheduled').toList();
                final replays = events.where((e) => e.status == 'ended').toList();

                return SliverMainAxisGroup(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          if (live.isNotEmpty)
                            _EventSection(
                              key: _liveSectionKey,
                              title: 'En direct maintenant',
                              subtitle: 'Rejoignez les événements live',
                              events: live,
                              icon: Icons.play_circle_filled,
                              accentColor: const Color(0xFFEF4444),
                            ),
                          if (upcoming.isNotEmpty)
                            _EventSection(
                              title: 'Prochainement',
                              subtitle: 'Ne manquez pas ces événements',
                              events: upcoming,
                              svgPath: 'assets/images/hour.svg',
                              accentColor: const Color(0xFFF59E0B),
                            ),
                          if (replays.isNotEmpty)
                            _EventSection(
                              title: 'Replays disponibles',
                              subtitle: 'Revivez les meilleurs moments',
                              events: replays,
                              svgPath: 'assets/images/replay.svg',
                              accentColor: const Color(0xFF3B82F6),
                            ),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: const Footer(key: Key('footer')),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$e',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _HeroSection extends StatelessWidget {
  final VoidCallback? onExploreTap;
  final VoidCallback? onLearnMoreTap;

  const _HeroSection({
    this.onExploreTap,
    this.onLearnMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: EdgeInsets.all(isWide ? 64 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A9FCC), Color(0xFF5BB7E0), Color(0xFF6ECFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A9FCC).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping en Direct',
            style: TextStyle(
              fontSize: isWide ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Découvrez des produits uniques lors d\'événements live interactifs',
            style: TextStyle(
              fontSize: isWide ? 20 : 16,
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: onExploreTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A9FCC),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Explorer maintenant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton(
                onPressed: onLearnMoreTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'En savoir plus',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(categoriesProvider);

    return asyncCategories.when(
      data: (categories) {
        // Helper function to get SVG path for category
        String? getSvgPath(String categoryName) {
          switch (categoryName) {
            case 'Mode':
              return 'assets/images/mode.svg';
            case 'Beauté':
              return 'assets/images/beauty.svg';
            case 'Électronique':
              return 'assets/images/electronics.svg';
            case 'Maison':
              return 'assets/images/home.svg';
            case 'Sport':
              return 'assets/images/sport.svg';
            default:
              return null;
          }
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ModernFilterChip(
              label: 'Tous',
              selected: true,
              onTap: () {
                // Stay on home page
              },
            ),
            ...categories.map((category) {
              return _ModernFilterChip(
                label: category.name,
                svgPath: getSvgPath(category.name),
                onTap: () => context.go('/category/${category.slug}'),
              );
            }),
          ],
        );
      },
      loading: () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _ModernFilterChip(label: 'Tous', selected: true),
          _ModernFilterChip(label: 'Mode', svgPath: 'assets/images/mode.svg'),
          _ModernFilterChip(label: 'Beauté', svgPath: 'assets/images/beauty.svg'),
          _ModernFilterChip(label: 'Électronique', svgPath: 'assets/images/electronics.svg'),
          _ModernFilterChip(label: 'Maison', svgPath: 'assets/images/home.svg'),
          _ModernFilterChip(label: 'Sport', svgPath: 'assets/images/sport.svg'),
        ],
      ),
      error: (_, __) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _ModernFilterChip(label: 'Tous', selected: true),
          _ModernFilterChip(label: 'Mode', svgPath: 'assets/images/mode.svg'),
          _ModernFilterChip(label: 'Beauté', svgPath: 'assets/images/beauty.svg'),
          _ModernFilterChip(label: 'Électronique', svgPath: 'assets/images/electronics.svg'),
          _ModernFilterChip(label: 'Maison', svgPath: 'assets/images/home.svg'),
          _ModernFilterChip(label: 'Sport', svgPath: 'assets/images/sport.svg'),
        ],
      ),
    );
  }
}

class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final String? svgPath;
  final VoidCallback? onTap;

  const _ModernFilterChip({
    required this.label,
    this.selected = false,
    this.svgPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgPath != null) ...[
              SvgPicture.asset(
                svgPath!,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  selected ? const Color(0xFF4A9FCC) : Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (bool value) {
          // Navigation is handled by InkWell onTap
          if (onTap != null) {
            onTap!();
          }
        },
        selectedColor: const Color(0xFF4A9FCC).withOpacity(0.15),
        backgroundColor: Colors.white,
        checkmarkColor: const Color(0xFF4A9FCC),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF4A9FCC) : Colors.grey[700],
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? const Color(0xFF4A9FCC) : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<LiveEvent> events;
  final IconData? icon;
  final String? svgPath;
  final Color accentColor;

  const _EventSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.events,
    this.icon,
    this.svgPath,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1400 ? 4 : (width >= 1024 ? 3 : (width >= 600 ? 2 : 1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: svgPath != null
                    ? SvgPicture.asset(
                        svgPath!,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
                      )
                    : Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1.35,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return RepaintBoundary(
                child: _ModernEventCard(event: event, accentColor: accentColor),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModernEventCard extends StatefulWidget {
  final LiveEvent event;
  final Color accentColor;

  const _ModernEventCard({
    required this.event,
    required this.accentColor,
  });

  @override
  State<_ModernEventCard> createState() => _ModernEventCardState();
}

class _ModernEventCardState extends State<_ModernEventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isLive = widget.event.status == 'live';
    final isUpcoming = widget.event.status == 'scheduled';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? widget.accentColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 12 : 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.go('/live/${widget.event.id}'),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: HeroImage(
                          imageUrl: widget.event.thumbnailUrl,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _ModernStatusBadge(event: widget.event),
                      ),
                      if (isLive)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.visibility, size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.event.viewerCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: widget.accentColor.withOpacity(0.2),
                            child: SvgPicture.asset(
                              'assets/images/shop.svg',
                              width: 14,
                              height: 14,
                              colorFilter: ColorFilter.mode(
                                widget.accentColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.event.seller.storeName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (isUpcoming) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/hour.svg',
                              width: 14,
                              height: 14,
                              colorFilter: ColorFilter.mode(
                                Colors.grey[500]!,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(widget.event.startTime),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${dateTime.day} ${months[dateTime.month - 1]} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _ModernStatusBadge extends StatelessWidget {
  final LiveEvent event;

  const _ModernStatusBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    final isLive = event.status == 'live';
    final isUpcoming = event.status == 'scheduled';

    Color color;
    String label;
    IconData? icon;

    if (isLive) {
      color = const Color(0xFFEF4444);
      label = 'EN DIRECT';
      icon = Icons.circle;
    } else if (isUpcoming) {
      color = const Color(0xFFF59E0B);
      label = 'BIENTÔT';
    } else {
      color = const Color(0xFF3B82F6);
      label = 'REPLAY';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(icon, size: 10, color: Colors.white),
            ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
