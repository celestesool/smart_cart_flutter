// 📁 lib/utils/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

Future<void> loginComoVisitante(BuildContext context) async {
  final url = Uri.parse('$apiBaseURL/token/visitante');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final respuesta = jsonDecode(response.body);
    final token = respuesta['token'];
    final id = respuesta['id']; // ⚠️ ¡Esto es lo que usas luego!

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('id_usuario', id); // ✅ GUARDA el ID también

    print('✅ TOKEN: $token');
    print('✅ ID USUARIO: $id');
    Navigator.pushReplacementNamed(context, '/catalogo');
  } else {
    print('❌ Error en loginComoVisitante: ${response.body}');
  }
}

// 📁 lib/utils/auth_service.dart

Future<void> cerrarSesion(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // 🧹 Limpia todo (token, id, etc.)

  Navigator.pushNamedAndRemoveUntil(
      context, '/', (route) => false); // 👈 Te regresa a la bienvenida
}
