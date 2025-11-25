import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../domain/entities/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
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
      
      emit(CartLoaded(items));
    } else {
      emit(CartLoaded([event.item]));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final items = List<CartItem>.from(currentState.items)
        ..removeWhere((item) => item.item.id == event.itemId);
      emit(CartLoaded(items));
    }
  }

  void _onUpdateCartItemQuantity(UpdateCartItemQuantity event, Emitter<CartState> emit) {
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
      
      emit(CartLoaded(items));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartLoaded([]));
  }
}
