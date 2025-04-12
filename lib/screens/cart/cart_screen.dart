// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../config/api_config.dart'; // ip 

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<bool> validarStock(BuildContext context) async {
    final token = await getToken();

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/detalle_carrito/validar'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) return true;

      final decoded = jsonDecode(res.body);
      final errores = decoded['problemas'];
      if (errores == null) throw Exception('Respuesta sin campo "problemas"');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error de stock'),
          content: Text(
            errores
                .map<String>(
                    (e) => '${e['producto']}: Solo ${e['stock']} disponibles')
                .join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error inesperado'),
          content:
              const Text('No se pudo validar el stock. Intenta más tarde.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }

    return false;
  }

  Future<String> getToken() async {
    final response = await http.get(
      Uri.parse('$baseUrl/token/visitante'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('No se pudo obtener el token');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      CartItem cartItem = cart.items[index];
                      Product product = cartItem.product;
                      int cantidad = cartItem.quantity;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        color: const Color(0xFFF5F5F5),
                        child: ListTile(
                          leading: Image.network(product.imageUrl, width: 40),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cantidad:'),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: cantidad > 1
                                        ? () {
                                            cart.updateQuantity(
                                                product, cantidad - 1);
                                          }
                                        : null,
                                  ),
                                  Text('$cantidad'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      cart.updateQuantity(
                                          product, cantidad + 1);
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                  'Precio unitario: \$${product.price.toStringAsFixed(2)}'),
                              Text(
                                  'Subtotal: \$${(product.price * cantidad).toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              cart.removeFromCart(product);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 18)),
                          Text(
                            '\$${cart.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final valido = await validarStock(context);
                            if (!valido) return;

                            final confirmacion = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar compra'),
                                content: const Text(
                                    '¿Estás seguro de que deseas confirmar la compra?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Confirmar'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmacion == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      '¡Compra confirmada exitosamente! 🚀'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              cart.clearCart();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Confirmar compra',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
