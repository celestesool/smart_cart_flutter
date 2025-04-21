// 📁 lib/screens/voice_screen.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smart_cart_flutter/services/voz_service.dart'; // Ajustá el nombre si tu proyecto se llama distinto
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_cart_flutter/screens/cart_screen.dart'; // ☝️ Al inicio del archivo si no está

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _textoReconocido = 'Presiona el micrófono para empezar...';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _enviarComandoReconocido() async {
    if (_textoReconocido.trim().isEmpty) {
      print("⚠️ Texto vacío, no se envía nada");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getInt('id_usuario') ?? 0;
    print("🧍 ID actual desde SharedPreferences: $idUsuario");

    print("📤 Enviando texto al backend: $_textoReconocido");

    try {
      final respuestaRaw =
          await VozService.procesarTexto(_textoReconocido, idUsuario);
      print("🧾 Respuesta RAW del backend: $respuestaRaw");
      final data = jsonDecode(respuestaRaw);
      final accion = data["accion"] ?? "";
      final mensaje = data["mensaje"] ?? "";

      print("📦 Acción: $accion");
      print("📥 Mensaje: $mensaje");

// ✅ Agrega esto exactamente aquí
      if (accion == "ver_carrito") {
        Navigator.pushNamed(context, '/cart');
        return;
      }

      if (accion == "pagar") {
        Navigator.pushNamed(context, '/checkout');
        return;
      }
      if (accion == "ver_carrito") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        return;
      }
      print("📦 Acción: $accion");
      print("📥 Mensaje: $mensaje");

      if (accion == "ver_carrito") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        return;
      }
      if (accion == "pagar") {
        Navigator.pushNamed(context, '/checkout');
        return;
      }

      // Solo mostrar si no hubo navegación
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Respuesta del sistema"),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ Error al interpretar la respuesta del backend: $e");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Error"),
          content: Text("Respuesta inválida del servidor."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _escuchar() async {
    print('🎤 Intentando inicializar...');
    if (!_isListening) {
      bool disponible = await _speech.initialize(
        onStatus: (val) {
          print('🟡 STATUS: $val');
          if (val == 'notListening' && _textoReconocido.trim().isEmpty) {
            print('⚠️ No se detectó voz');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se detectó voz, intenta nuevamente'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onError: (val) {
          print('❌ ERROR de reconocimiento: $val');
        },
      );

      if (disponible) {
        print('✅ Reconocimiento de voz listo');
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'es_BO', // o 'es_ES' o 'es-US' según idioma configurado
          onResult: (result) {
            print("🗣️ Voz reconocida: ${result.recognizedWords}");
            print('📢 Resultado: ${result.recognizedWords}');
            setState(() {
              _textoReconocido = result.recognizedWords;
            });

            if (result.finalResult &&
                result.recognizedWords.trim().isNotEmpty) {
              _enviarComandoReconocido(); // 🚀 Aquí se envía al backend
            }
          },
        );
      } else {
        print('❌ El reconocimiento no está disponible');
      }
    } else {
      print('🛑 Parando...');
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda por Voz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Texto reconocido:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _textoReconocido,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _escuchar,
            backgroundColor: _isListening ? Colors.red : Colors.green,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _textoReconocido = 'Samsung Galaxy A54';
              });
            },
            icon: const Icon(Icons.text_fields),
            label: const Text('Simular voz'),
            backgroundColor: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
