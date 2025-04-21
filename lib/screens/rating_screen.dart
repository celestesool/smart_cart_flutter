// 📁 lib/screens/rating_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RatingScreen extends StatefulWidget {
  final int idCompra;

  const RatingScreen({super.key, required this.idCompra});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _estrellas = 0;
  bool _enviado = false;

  Future<void> enviarCalificacion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url =
        Uri.parse('https://smartcart-backend-klyi.onrender.com/calificaciones');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '{"id_compra": ${widget.idCompra}, "estrellas": $_estrellas}',
      );

      if (response.statusCode == 200) {
        setState(() {
          _enviado = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Gracias por su calificación')),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/catalogo', (r) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error al enviar calificación')),
        );
      }
    } catch (e) {
      print("❌ Error al enviar: $e");
    }
  }

  Widget construirEstrellas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final index = i + 1;
        return IconButton(
          icon: Icon(
            Icons.star,
            color: _estrellas >= index ? Colors.amber : Colors.grey,
          ),
          onPressed: () => setState(() => _estrellas = index),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Califica tu compra")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _enviado
              ? const Text("¡Gracias por calificar!",
                  style: TextStyle(fontSize: 18))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿Qué tan satisfecho estás?",
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    construirEstrellas(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _estrellas == 0 ? null : () => enviarCalificacion(),
                      child: const Text("Enviar"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
