// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

Future<List<CartItem>> obtenerDetalleCarritoDesdeBackend() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('http://192.168.0.12:5000/detalle_carrito/ver');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
  print('📦 BODY DETALLE: ${response.body}'); // 👈 ESTE print va aquí

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    return (data['detalle_carrito'] as List).map((item) {
      final producto = Product(
        id: item['id'],
        nombre: item['producto'], // Solo el nombre llega
        descripcion: '',
        precio: item['precio_unitario'].toDouble(),
        stock: 0,
        categoria: '',
        imagen: '',
      );

      return CartItem(product: producto, quantity: item['cantidad']);
    }).toList();
  } else {
    print('❌ Error al obtener detalle del carrito: ${response.statusCode}');
    return [];
  }
}

Future<bool> agregarProductoAlCarrito(Product producto, int cantidad) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final url = Uri.parse('http://192.168.0.12:5000/detalle_carrito/agregar');

  final body = jsonEncode({
    "id_producto": producto.id,
    "cantidad": cantidad,
    "precio_unitario": producto.precio, // 👈 ✅ AÑADIDO
  });

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.post(url, body: body, headers: headers);
  return response.statusCode == 200;
}

Future<bool> actualizarCantidadProducto(
    int idDetalle, int nuevaCantidad) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse(
      'http://192.168.0.12:5000/detalle_carrito/actualizar/$idDetalle');

  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'cantidad': nuevaCantidad,
    }),
  );

  print(
      "Enviando actualización: id_detalle=$idDetalle, cantidad=$nuevaCantidad");
  print("Respuesta: ${response.statusCode} - ${response.body}");

  return response.statusCode == 200;
}

Future<bool> eliminarProductoDelCarrito(int idProducto) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final url = Uri.parse(
      'http://192.168.0.12:5000/detalle_carrito/eliminar/$idProducto');

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print("🗑️ Producto eliminado del carrito");
    return true;
  } else {
    print("❌ Error al eliminar del carrito: ${response.statusCode}");
    return false;
  }
}

Future<void> vaciarCarritoDesdeBackend() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.delete(
    Uri.parse('http://192.168.0.12:5000/detalle_carrito/vaciar'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    print("🧹 Carrito vaciado desde el backend");
  } else {
    print("❌ Error al vaciar el carrito: ${response.statusCode}");
  }
}
