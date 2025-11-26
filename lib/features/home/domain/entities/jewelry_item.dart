import 'package:equatable/equatable.dart';

class JewelryItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final String material;
  final double weight;
  final bool inStock;
  final double? discount;
  final int reviewCount;
  final double rating;

  const JewelryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.material,
    required this.weight,
    this.inStock = true,
    this.discount,
    this.reviewCount = 0,
    this.rating = 0.0,
  });

  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'images': images,
    'material': material,
    'weight': weight,
    'inStock': inStock,
    'discount': discount,
    'reviewCount': reviewCount,
    'rating': rating,
  };

  factory JewelryItem.fromJson(Map<String, dynamic> json) => JewelryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    category: json['category'] as String,
    images: List<String>.from(json['images'] as List),
    material: json['material'] as String,
    weight: (json['weight'] as num).toDouble(),
    inStock: json['inStock'] as bool? ?? true,
    discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
    reviewCount: json['reviewCount'] as int? ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        images,
        material,
        weight,
        inStock,
        discount,
        reviewCount,
        rating,
      ];
}
