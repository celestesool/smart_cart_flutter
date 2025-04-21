// 📁 lib/widgets/mic_button.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/voz_service.dart';
import 'dart:convert';
import '../screens/cart_screen.dart'; // ✅ Importamos CartScreenState

class MicButton extends StatefulWidget {
  const MicButton({super.key});

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _texto = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _iniciarEscucha() async {
    if (!_isListening) {
      bool disponible = await _speech.initialize(
        onStatus: (val) => print("🟡 STATUS: $val"),
        onError: (val) => print("❌ Error: $val"),
      );

      if (disponible) {
        print("🎤 Reconocimiento iniciado");
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'es_BO',
          onResult: (result) async {
            _texto = result.recognizedWords;
            print("🗣️ Texto reconocido: $_texto");

            if (result.finalResult && _texto.isNotEmpty) {
              await _procesarComando(_texto);
            }
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
      print("🛑 Escucha detenida");
    }
  }

  Future<void> _procesarComando(String texto) async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getInt('id_usuario') ?? 0;

    final raw = await VozService.procesarTexto(texto, idUsuario);
    print("📦 Respuesta del backend: $raw");

    try {
      final data = jsonDecode(raw);
      final accion = data["accion"];
      final mensaje = data["mensaje"] ?? "Acción realizada";

      print("📥 Acción: $accion");
      print("📨 Mensaje: $mensaje");

// 🔁 Siempre que estés en el carrito y cambie algo (aunque no haya "accion")
      if (ModalRoute.of(context)?.settings.name == '/cart') {
        print("🔄 En carrito, intentando actualizar visualmente...");

        final cartState = context.findAncestorStateOfType<CartScreenState>();
        if (cartState != null) {
          print("✅ CartScreenState encontrado, ejecutando cargarCarrito()");
          cartState.cargarCarrito();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje), duration: Duration(seconds: 2)),
          );
        } else {
          print("⚠️ CartScreenState no encontrado");
        }
        return;
      }

// 🛒 Si vino explícitamente la acción, puede redirigir
      if (accion == "ver_carrito") {
        Navigator.pushNamed(context, '/cart');
        return;
      }
      if (accion == "pagar") {
        Navigator.pushNamed(context, '/checkout');
        return;
      }

      if (accion == "pagar") {
        Navigator.pushNamed(context, '/checkout');
        return;
      }

      // Otra respuesta del backend
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Respuesta"),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ Error interpretando la respuesta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _iniciarEscucha,
      backgroundColor: _isListening ? Colors.red : Colors.green,
      tooltip: "Reconocimiento por voz",
      child: Icon(_isListening ? Icons.mic_off : Icons.mic),
    );
  }
}
