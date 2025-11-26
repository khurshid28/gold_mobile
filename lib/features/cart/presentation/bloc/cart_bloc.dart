import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../domain/entities/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final SharedPreferences prefs;
  
  CartBloc(this.prefs) : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
    on<LoadCart>(_onLoadCart);
    
    // Load cart on initialization
    add(LoadCart());
  }

  Future<void> _saveCart(List<CartItem> items) async {
    try {
      final cartJson = items.map((item) => item.toJson()).toList();
      await prefs.setString('cart_items', jsonEncode(cartJson));
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    try {
      final cartString = prefs.getString('cart_items');
      if (cartString != null && cartString.isNotEmpty) {
        final List<dynamic> cartJson = jsonDecode(cartString);
        final items = cartJson
            .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
            .toList();
        emit(CartLoaded(items));
      } else {
        emit(const CartLoaded([]));
      }
    } catch (e) {
      print('Error loading cart: $e');
      emit(const CartLoaded([]));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = List<CartItem>.from(currentState.items);
      final existingIndex = items.indexWhere((item) => item.item.id == event.item.item.id);
      
      if (existingIndex != -1) {
        // Item already exists, increase quantity
        items[existingIndex] = items[existingIndex].copyWith(
          quantity: items[existingIndex].quantity + event.item.quantity,
        );
      } else {
        // New item
        items.add(event.item);
      }
      
      await _saveCart(items);
      emit(CartLoaded(items));
    } else {
      await _saveCart([event.item]);
      emit(CartLoaded([event.item]));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = List<CartItem>.from(currentState.items)
        ..removeWhere((item) => item.item.id == event.itemId);
      await _saveCart(items);
      emit(CartLoaded(items));
    }
  }

  void _onUpdateCartItemQuantity(UpdateCartItemQuantity event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = List<CartItem>.from(currentState.items);
      final index = items.indexWhere((item) => item.item.id == event.itemId);
      
      if (index != -1) {
        if (event.quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index] = items[index].copyWith(quantity: event.quantity);
        }
      }
      
      await _saveCart(items);
      emit(CartLoaded(items));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    await prefs.remove('cart_items');
    emit(const CartLoaded([]));
  }
}
