// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/guest_provider.dart';
import '../../config/api_config.dart'; // 🌐 baseUrl centralizado

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _enterAsGuest(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/token/visitante'));
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final email = data['email'];

        // Guardar en Provider
        Provider.of<GuestProvider>(context, listen: false)
            .setGuestData(token: token, email: email);

        Navigator.pushReplacementNamed(context, '/catalog');
      } else {
        print('❌ Error al obtener token visitante: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al ingresar como visitante')),
        );
      }
    } catch (e) {
      print('❌ Excepción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fallo la conexión al servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_checkout,
                  size: 80, color: Color.fromARGB(255, 7, 48, 125)),
              const SizedBox(height: 20),
              const Text(
                'Compra fácil, rápida y sin filas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Explora nuestro catálogo y arma tu carrito desde tu celular. ¡Tu compra en segundos!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _enterAsGuest(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 67, 112, 175),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
