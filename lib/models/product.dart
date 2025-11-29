/// Model representing a product in the catalog, based on `mock-api-data.json`.
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> images;
  final String thumbnail;
  final int stock;
  final ProductVariations? variations;
  final bool isFeatured;
  final DateTime? featuredAt;
  final String category;
  final double rating;
  final int reviewsCount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    required this.images,
    required this.thumbnail,
    required this.stock,
    this.variations,
    required this.isFeatured,
    this.featuredAt,
    required this.category,
    required this.rating,
    required this.reviewsCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      salePrice: json['salePrice'] != null
          ? (json['salePrice'] as num).toDouble()
          : null,
      images: (json['images'] as List<dynamic>).cast<String>(),
      thumbnail: json['thumbnail'] as String,
      stock: json['stock'] as int,
      variations: json['variations'] != null
          ? ProductVariations.fromJson(
              json['variations'] as Map<String, dynamic>,
            )
          : null,
      isFeatured: json['isFeatured'] as bool,
      featuredAt: json['featuredAt'] != null
          ? DateTime.parse(json['featuredAt'] as String)
          : null,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'images': images,
      'thumbnail': thumbnail,
      'stock': stock,
      'variations': variations?.toJson(),
      'isFeatured': isFeatured,
      'featuredAt': featuredAt?.toUtc().toIso8601String(),
      'category': category,
      'rating': rating,
      'reviewsCount': reviewsCount,
    };
  }
}

/// Flexible variations model: keys like "size", "color", "type", "storage" map
/// to a list of possible options.
class ProductVariations {
  final Map<String, List<String>> options;

  const ProductVariations({required this.options});

  factory ProductVariations.fromJson(Map<String, dynamic> json) {
    final map = <String, List<String>>{};
    for (final entry in json.entries) {
      if (entry.value is List) {
        map[entry.key] =
            (entry.value as List<dynamic>).map((e) => e.toString()).toList();
      }
    }
    return ProductVariations(options: map);
  }

  Map<String, dynamic> toJson() {
    return options.map((key, value) => MapEntry(key, value));
  }
}


