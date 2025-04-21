// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class VozService {
  static const String baseUrl = "http://10.0.2.2:5000";

  static Future<String> procesarTexto(String texto, int idUsuario) async {
    final url = Uri.parse('$baseUrl/voz/procesar');

    print("📡 POST → $url");
    print("📝 Payload: texto = \"$texto\", id_usuario = $idUsuario");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "texto": texto,
          "id_usuario": idUsuario,
        }),
      );

      print("🔁 Código de respuesta: ${response.statusCode}");
      print("📦 Cuerpo: ${response.body}");

      if (response.statusCode == 200) {
        return response
            .body; // ✅ Devuelve el String completo para parsear luego
      } else {
        return "⚠️ Error ${response.statusCode}";
      }
    } catch (e) {
      print("❌ Error al conectar con el backend: $e");
      return "Error de conexión";
    }
  }
}
