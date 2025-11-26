import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/jewelry_item.dart';

class CartItem extends Equatable {
  final JewelryItem item;
  final int quantity;

  const CartItem({
    required this.item,
    required this.quantity,
  });

  double get totalPrice => item.finalPrice * quantity;

  CartItem copyWith({
    JewelryItem? item,
    int? quantity,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    item: JewelryItem.fromJson(json['item'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
  );

  @override
  List<Object?> get props => [item, quantity];
}
