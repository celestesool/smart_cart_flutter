// 📁 lib/models/cart_item.dart

import 'product.dart';

class CartItem {
  final Product product;
  int quantity; // ✅ Aquí está la propiedad que faltaba

  CartItem({required this.product, required this.quantity});
}
