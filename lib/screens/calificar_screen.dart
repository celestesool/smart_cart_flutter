// 📁 lib/screens/calificar_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalificarScreen extends StatefulWidget {
  const CalificarScreen({super.key});

  @override
  State<CalificarScreen> createState() => _CalificarScreenState();
}

class _CalificarScreenState extends State<CalificarScreen> {
  int _valorSeleccionado = 0;
  bool _enviado = false;

  Future<void> _enviarCalificacion(int idCompra) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        Uri.parse("https://smartcart-backend-klyi.onrender.com/calificaciones");

    print("📦 Enviando calificación:");
    print("➡️ ID Compra: $idCompra");
    print("⭐ Valor: $_valorSeleccionado");
    print("🔐 Token: ${token?.substring(0, 10)}...");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_compra': idCompra,
        'puntuacion': _valorSeleccionado, //
      }),
    );

    print("Respuesta status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        _enviado = true;
      });
      // Redirigir automáticamente al catálogo
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          print("⏩ Redirigiendo al catálogo automáticamente...");
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/catalog',
            (route) => false,
          );
        } else {
          print("⚠️ Widget desmontado, no se puede redirigir");
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al enviar calificación")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final argumentos =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final int idCompra = argumentos?['id_compra'] ?? 0;

    print("🧾 ID de compra recibido en calificación: $idCompra");

    return Scaffold(
      appBar: AppBar(title: const Text("Calificar experiencia")),
      body: Center(
        child: _enviado
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 20),
                  Text("¡Gracias por tu calificación!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Cómo calificarías tu experiencia?",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _valorSeleccionado
                              ? Icons.star
                              : Icons.star_border,
                          size: 40,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _valorSeleccionado = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _valorSeleccionado == 0
                        ? null
                        : () => _enviarCalificacion(idCompra),
                    child: const Text("Enviar calificación"),
                  ),
                ],
              ),
      ),
    );
  }
}
