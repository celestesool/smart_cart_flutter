// 📁 lib/screens/recibo_screen.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReciboScreen extends StatefulWidget {
  final int idCompra;
  const ReciboScreen({super.key, required this.idCompra});

  @override
  State<ReciboScreen> createState() => _ReciboScreenState();
}

class _ReciboScreenState extends State<ReciboScreen> {
  Map<String, dynamic>? compra;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerRecibo();
  }

  Future<void> obtenerRecibo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url =
        Uri.parse('http://192.168.0.12:5000/compras/${widget.idCompra}');

    for (int intento = 1; intento <= 3; intento++) {
      try {
        final response = await http.get(url, headers: {
          'Authorization': 'Bearer $token',
        });

        print('📥 GET /compras/${widget.idCompra} → ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('📦 BODY: $data');

          setState(() {
            compra = data;
            cargando = false;
          });
          return;
        } else {
          print('❌ Intento $intento fallido, reintentando...');
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } catch (e) {
        print('❌ Excepción en intento $intento: $e');
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (compra == null) {
      return const Scaffold(
        body: Center(child: Text('❌ No se pudo cargar el recibo')),
      );
    }

    final productos = compra!['productos'] as List<dynamic>;
    print("📄 Productos en el recibo: $productos");

    final nombre = compra!['nombre_cliente'] ?? 'Sin nombre';
    final nit = compra!['nit_cliente'] ?? 'S/N';
    final total = compra!['total'];
    final descuento = compra!['descuento'];
    final totalFinal = compra!['total_final'];
    final fecha = compra!['fecha'];
    final idCompra = compra!['id'];

    print("🧾 MOSTRANDO RECIBO");
    print("👤 Cliente: $nombre | NIT: $nit");
    print("🛍️ Productos: ${productos.length}");
    print("💸 Total: $total | Descuento: $descuento | Final: $totalFinal");
    print("🆔 ID Compra: $idCompra");

    return Scaffold(
      appBar: AppBar(title: const Text('Recibo de Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: $nombre'),
            Text('NIT: $nit'),
            Text('Fecha: $fecha'),
            const SizedBox(height: 16),
            const Text(
              'Productos Comprados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final item = productos[index];
                  return ListTile(
                    title: Text(item['producto'] ?? ''),
                    subtitle: Text('Cantidad: ${item['cantidad']}'),
                    trailing: Text('Bs ${item['subtotal'].toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(),
            Text('Total: Bs ${total.toStringAsFixed(2)}'),
            Text('Descuento: Bs ${descuento.toStringAsFixed(2)}'),
            Text(
              'Total Final: Bs ${totalFinal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Calificar compra'),
                onPressed: () {
                  print("🔁 Redirigiendo a /calificar con id: $idCompra");
                  Navigator.pushNamed(
                    context,
                    '/calificar',
                    arguments: {'id_compra': idCompra},
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
