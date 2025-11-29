import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/live_event.dart';

/// Card widget displaying event information (title, seller, description)
class EventInfoCard extends StatelessWidget {
  const EventInfoCard({
    super.key,
    required this.event,
    this.isWide = false,
  });

  final LiveEvent event;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 16 : 20,
        vertical: isWide ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isWide ? 0.06 : 0.08),
            blurRadius: isWide ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.title,
            style: TextStyle(
              fontSize: isWide ? 22 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              height: isWide ? 1.2 : 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isWide ? 6 : 12),
          Row(
            children: [
              if (isWide)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A9FCC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/shop.svg',
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF4A9FCC),
                      BlendMode.srcIn,
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF4A9FCC).withOpacity(0.15),
                  child: SvgPicture.asset(
                    'assets/images/shop.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF4A9FCC),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              SizedBox(width: isWide ? 8 : 10),
              Flexible(
                child: Text(
                  event.seller.storeName,
                  style: TextStyle(
                    fontSize: isWide ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (event.description.isNotEmpty && isWide) ...[
            const SizedBox(height: 8),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

