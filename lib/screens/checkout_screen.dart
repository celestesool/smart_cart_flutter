// 📁 lib/screens/checkout_screen.dart

// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/mic_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confirmarYRedirigir(); // 👈 Llamada separada
    });
  }

  Future<void> _confirmarYRedirigir() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final idCompra = args?['id_compra'] ?? 0;
    final idCarrito = args?['id_carrito'] ?? 0;
    print(
        '🧾 Recibido en checkout → ID COMPRA: $idCompra, ID CARRITO: $idCarrito');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse('http://192.168.0.12:5000/ventas/confirmar/$idCarrito');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("📥 Respuesta confirmar venta: ${response.statusCode}");
    print("📦 Body: ${response.body}");

    Future.delayed(const Duration(seconds: 2), () {
      print("⏩ Redirigiendo a /recibo con id_compra: $idCompra");

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/recibo',
        (route) => false,
        arguments: {'id_compra': idCompra},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("✅ CheckoutScreen mostrado correctamente");

    return Scaffold(
      appBar: AppBar(title: const Text("Finalizar Compra")),
      body: const Center(
        child: Text(
          "✅ Gracias por su compra",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: const MicButton(),
    );
  }
}
