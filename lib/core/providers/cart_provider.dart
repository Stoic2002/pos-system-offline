import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + item.subtotal);
  }

  void addProduct(Product product) {
    if (product.stock <= 0) return; // Cannot add empty stock

    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Increment quantity
      final existingItem = state[existingIndex];
      // Check stock limit
      if (existingItem.quantity < product.stock) {
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
        final newState = [...state];
        newState[existingIndex] = updatedItem;
        state = newState;
      }
    } else {
      // Add new item
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void decrementProduct(Product product) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      final existingItem = state[existingIndex];
      if (existingItem.quantity > 1) {
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity - 1,
        );
        final newState = [...state];
        newState[existingIndex] = updatedItem;
        state = newState;
      } else {
        // Remove from cart
        state = state.where((item) => item.product.id != product.id).toList();
      }
    }
  }

  void removeProduct(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void setQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeProduct(product);
      return;
    }

    // Check stock limit
    final validQuantity = quantity > product.stock ? product.stock : quantity;

    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      final updatedItem = state[existingIndex].copyWith(
        quantity: validQuantity,
      );
      final newState = [...state];
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      state = [...state, CartItem(product: product, quantity: validQuantity)];
    }
  }

  void clear() {
    state = [];
  }
}
