/// Model representing a seller (vendor) in a live event.
class Seller {
  final String id;
  final String name;
  final String storeName;
  final String avatar;

  const Seller({
    required this.id,
    required this.name,
    required this.storeName,
    required this.avatar,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      storeName: (json['storeName'] as String?) ?? '',
      avatar: (json['avatar'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'storeName': storeName,
      'avatar': avatar,
    };
  }
}


