import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text('Categoría: ${product.category}\n\$${product.price}'),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () {
            cart.addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} agregado al carrito')),
            );
          },
        ),
      ),
    );
  }
}
