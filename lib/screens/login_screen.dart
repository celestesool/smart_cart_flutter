import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'catalog_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> loginComoVisitante(BuildContext context) async {
    final url = Uri.parse(
        'https://smartcart-backend-klyi.onrender.com/token/visitante');
    try {
      final response = await http.get(url).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final datos = json.decode(response.body);

        final token = datos['token'];
        final id = datos['id']; // 👈 extrae también el ID del usuario
        print("✅ TOKEN: $token");

        // 🔐 Guardar token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('id_usuario', id); // 👈 ¡GUARDA EL ID!
        // Ir al catálogo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CatalogoScreen()),
        );
      } else {
        throw Exception("Código HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error en loginComoVisitante: $e");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error de red: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_checkout,
                    size: 100, color: Color(0xFF43A047)),
                const SizedBox(height: 20),
                const Text(
                  "Compra fácil, rápida y sin filas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Explora nuestro catálogo y arma tu carrito desde tu celular. ¡Tu compra en segundos!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => loginComoVisitante(context),
                    child: const Text("Continuar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
