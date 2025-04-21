import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> producto;

  const ProductCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        leading: Image.network(
          producto['imagen'] != null
              ? "http://192.168.0.12:5000/uploads/${producto['imagen']}"
              : "https://via.placeholder.com/50",
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(producto['nombre']),
        subtitle: Text("${producto['descripcion']} - \$${producto['precio']}"),
        trailing: Text(
          producto['estado'] ?? '✔️',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
