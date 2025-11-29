import 'seller.dart';

/// Model representing a live shopping event, based on `mock-api-data.json`.
class LiveEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // "live", "scheduled", "ended", etc.
  final Seller seller;

  /// List of product ids associated with this live event.
  final List<String> products;

  /// Id of the featured product, if any.
  final String? featuredProduct;

  final int viewerCount;
  final String? streamUrl;
  final String? replayUrl;
  final String thumbnailUrl;

  const LiveEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.seller,
    required this.products,
    this.featuredProduct,
    required this.viewerCount,
    this.streamUrl,
    this.replayUrl,
    required this.thumbnailUrl,
  });

  factory LiveEvent.fromJson(Map<String, dynamic> json) {
    return LiveEvent(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : DateTime.now(),
      status: (json['status'] as String?) ?? 'scheduled',
      seller: json['seller'] != null
          ? Seller.fromJson(json['seller'] as Map<String, dynamic>)
          : throw ArgumentError('Seller is required'),
      products: json['products'] != null
          ? (json['products'] as List<dynamic>).cast<String>()
          : <String>[],
      featuredProduct: json['featuredProduct'] as String?,
      viewerCount: (json['viewerCount'] as int?) ?? 0,
      streamUrl: json['streamUrl'] as String?,
      replayUrl: json['replayUrl'] as String?,
      thumbnailUrl: (json['thumbnailUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'status': status,
      'seller': seller.toJson(),
      'products': products,
      'featuredProduct': featuredProduct,
      'viewerCount': viewerCount,
      'streamUrl': streamUrl,
      'replayUrl': replayUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

