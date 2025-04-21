// 📁 lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../utils/auth_service.dart'; // 👈 para usar loginComoVisitante()

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> continuar(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bienvenida_vista', true); // ✅ Marcar como vista

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(Icons.shopping_cart_checkout,
                  size: 100, color: Color(0xFF43A047)),
              const SizedBox(height: 24),
              const Text(
                'Compra fácil, rápida y sin filas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Explora nuestro catálogo y arma tu carrito desde tu celular. ¡Tu compra en segundos!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              // ✅ Botón "Continuar" (login)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => continuar(context),
                  child: const Text('Continuar'),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Botón "Entrar como visitante"
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => loginComoVisitante(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF43A047),
                    side: const BorderSide(color: Color(0xFF43A047)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Entrar como visitante'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
