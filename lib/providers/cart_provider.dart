import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index] = CartItem(
        product: product,
        quantity: _items[index].quantity + 1,
      );
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }
  void updateQuantity(Product product, int quantity) {
    for (var item in _items) {
      if (item.product.id == product.id) {
        item.quantity = quantity;
        break;
      }
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(
        0, (sum, item) => sum + item.product.price * item.quantity);
  }
}
