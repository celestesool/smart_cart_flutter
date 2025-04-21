// 📁 lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/cart_service.dart';
import '../utils/compra_service.dart';
import '../widgets/mic_button.dart'; // 👈 botón flotante de micrófono
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> _cartFuture;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    cargarCarrito(); // 👈 esto permitirá recargar incluso cuando vuelvas a la pantalla
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cargarCarrito(); // 👈 cada vez que se vuelve a esta pantalla, se recarga
  }

  void cargarCarrito() {
    setState(() {
      _cartFuture = obtenerDetalleCarritoDesdeBackend();
    });
  }

  double calcularTotal() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + item.product.precio * item.quantity,
    );
  }

  void actualizarCantidad(CartItem item, int nuevaCantidad) async {
    final ok = await actualizarCantidadProducto(item.product.id, nuevaCantidad);
    if (ok) {
      setState(() {
        item.quantity = nuevaCantidad;
      });
    }
  }

  void eliminarProducto(CartItem item) async {
    final ok = await eliminarProductoDelCarrito(item.product.id);
    if (ok) {
      setState(() {
        _cartItems.remove(item);
      });
    }
  }

  void mostrarDialogoPago() {
    String nombre = '';
    String nit = '';

    showDialog(
      context: context,
      builder: (BuildContext contextDialogo) {
        return AlertDialog(
          title: const Text('Datos opcionales para la factura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => nombre = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'NIT'),
                keyboardType: TextInputType.number,
                onChanged: (value) => nit = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(contextDialogo).pop(),
            ),
            ElevatedButton(
              child: const Text('Pagar'),
              onPressed: () {
                Navigator.of(contextDialogo).pop(); // Cerramos diálogo
                procesarPago(nombre, nit); // Llamamos fuera del diálogo
              },
            ),
          ],
        );
      },
    );
  }

  void procesarPago(String nombre, String nit) async {
    print("📤 Enviando pago...");
    print("👤 Nombre: $nombre");
    print("🧾 NIT: $nit");

    final prefs = await SharedPreferences.getInstance();

    final idCompra = await confirmarCompraConDatos(nombre: nombre, nit: nit);
    final idCarrito = prefs.getInt('id_carrito') ?? 0;

    print("📥 ID COMPRA recibido: $idCompra");
    print("📦 ID CARRITO desde local: $idCarrito");

    if (idCompra != null) {
      print("✅ Compra confirmada, redirigiendo...");
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/checkout',
          (route) => false,
          arguments: {
            'id_compra': idCompra,
            'id_carrito': idCarrito,
          },
        );
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al confirmar la compra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      floatingActionButton: MicButton(),
      body: FutureBuilder<List<CartItem>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tu carrito está vacío"));
          }

          _cartItems = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    final producto = item.product;
                    final cantidad = item.quantity;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      color: const Color(0xFFF5F5F5),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Image.network(
                              producto.imagen != null &&
                                      producto.imagen!.isNotEmpty
                                  ? "http://192.168.0.12:5000/uploads/${producto.imagen}"
                                  : "https://via.placeholder.com/50x50?text=IMG",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image,
                                      size: 50, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(producto.nombre,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text("Cantidad: "),
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: cantidad > 1
                                            ? () => actualizarCantidad(
                                                item, cantidad - 1)
                                            : null,
                                      ),
                                      Text('$cantidad'),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => actualizarCantidad(
                                            item, cantidad + 1),
                                      ),
                                    ],
                                  ),
                                  Text(
                                      "Precio: Bs ${producto.precio.toStringAsFixed(2)}"),
                                  Text(
                                      "Subtotal: Bs ${(producto.precio * cantidad).toStringAsFixed(2)}"),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarProducto(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:", style: TextStyle(fontSize: 18)),
                        Text(
                          "Bs ${calcularTotal().toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _cartItems.isEmpty ? null : mostrarDialogoPago,
                        child: const Text("Confirmar compra"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
