import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/live_event.dart';
import '../../providers/live_event_provider.dart';
import '../../utils/constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(liveEventsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(liveEventsProvider);
          await ref.read(liveEventsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            _HomeHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _SearchAndFilters(),
              ),
            ),
            asyncEvents.when(
              data: (events) {
                final live =
                    events.where((e) => e.status == 'live').toList();
                final upcoming = events
                    .where((e) => e.status == 'scheduled')
                    .toList();
                final replays =
                    events.where((e) => e.status == 'ended').toList();

                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (live.isNotEmpty)
                        _EventSection(
                          title: 'Événements en direct',
                          events: live,
                        ),
                      if (upcoming.isNotEmpty)
                        _EventSection(
                          title: 'Événements à venir',
                          events: upcoming,
                        ),
                      if (replays.isNotEmpty)
                        _EventSection(
                          title: 'Replays',
                          events: replays,
                        ),
                      const _HomeFooter(),
                    ],
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Text('Erreur de chargement : $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      titleSpacing: 16,
      title: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined),
          const SizedBox(width: 8),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          if (isWide)
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Accueil'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Catégories'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Mes commandes'),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    final searchField = Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un événement, un vendeur...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
        ),
      ),
    );

    final filters = Wrap(
      spacing: 8,
      children: const [
        FilterChip(
          label: Text('Tous'),
          selected: true,
          onSelected: null,
        ),
        FilterChip(
          label: Text('Mode'),
          selected: false,
          onSelected: null,
        ),
        FilterChip(
          label: Text('Beauté'),
          selected: false,
          onSelected: null,
        ),
        FilterChip(
          label: Text('Électronique'),
          selected: false,
          onSelected: null,
        ),
      ],
    );

    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              searchField,
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
          const SizedBox(height: 8),
          filters,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        searchField,
        const SizedBox(height: 8),
        filters,
      ],
    );
  }
}

class _EventSection extends StatelessWidget {
  final String title;
  final List<LiveEvent> events;

  const _EventSection({
    required this.title,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 800;
    final crossAxisCount = isWide ? 3 : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isWide ? 2.4 : 1.6,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventCard(event: event);
            },
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final LiveEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = event.status == 'live';
    final isUpcoming = event.status == 'scheduled';

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.go('/live/${event.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    event.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: _StatusBadge(event: event),
                  ),
                  if (isLive)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.viewerCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.seller.storeName,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 4),
                  if (isUpcoming)
                    Text(
                      _formatDateTime(event.startTime),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final LiveEvent event;

  const _StatusBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    final isLive = event.status == 'live';
    final isUpcoming = event.status == 'scheduled';

    Color color;
    String label;

    if (isLive) {
      color = Colors.redAccent;
      label = 'LIVE';
    } else if (isUpcoming) {
      color = Colors.orangeAccent;
      label = 'Bientôt';
    } else {
      color = Colors.blueGrey;
      label = 'Replay';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.circle,
                size: 8,
                color: Colors.white,
              ),
            ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          Text(
            '© ${DateTime.now().year} ${AppConstants.appName}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Live shopping moderne, rapide et sécurisé.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

