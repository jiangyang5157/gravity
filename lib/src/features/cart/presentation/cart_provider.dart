import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gravity/src/features/products/domain/product.dart';
import '../domain/cart_item.dart';

part 'cart_provider.g.dart';

@riverpod
class Cart extends _$Cart {
  @override
  List<CartItem> build() {
    return [];
  }

  void addToCart(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final item = state[index];
      final newState = [...state];
      newState[index] = item.copyWith(quantity: item.quantity + 1);
      state = newState;
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeFromCart(Product product) {
    state = state.where((item) => item.product.id != product.id).toList();
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      state = [
        for (final item in state)
          if (item.product.id != product.id) item,
      ];
    } else {
      state = [
        for (final item in state)
          if (item.product.id == product.id)
            CartItem(product: product, quantity: quantity)
          else
            item,
      ];
    }
  }

  void clearCart() {
    state = [];
  }
}

@riverpod
double cartTotal(CartTotalRef ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.totalPrice);
}

@riverpod
int cartItemCount(CartItemCountRef ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
}
