import 'package:gold_mobile/features/home/domain/entities/jewelry_item.dart';

class JewelryItemModel extends JewelryItem {
  const JewelryItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    required super.images,
    required super.material,
    required super.weight,
    super.inStock,
    super.discount,
    super.reviewCount,
    super.rating,
  });

  factory JewelryItemModel.fromJson(Map<String, dynamic> json) {
    return JewelryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      material: json['material'] as String,
      weight: (json['weight'] as num).toDouble(),
      inStock: json['inStock'] as bool? ?? true,
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] as int? ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }
}
