// 📁 lib/utils/compra_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

Future<int?> confirmarCompraConDatos({String? nombre, String? nit}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final idUsuario = prefs.getInt('id_usuario');

  if (token == null || idUsuario == null) {
    print('🔎 TOKEN: $token');
    print('🔎 ID USUARIO: $idUsuario');
    return null;
  }

  final url = Uri.parse('$apiBaseURL/simular-pago-v2');

  final body = {
    'id_carrito': null,
    'metodo_pago': 'Simulado',
    'nombre_cliente': nombre ?? '',
    'nit_cliente': nit ?? '',
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  print('📦 RESPONSE ${response.statusCode}: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final idCompra = data['id_compra'];
    if (data['id_carrito'] != null) {
      final idCarrito = data['id_carrito'] as int;
      await prefs.setInt('id_carrito', idCarrito);
      print('💾 ID CARRITO guardado: $idCarrito');
    } else {
      print('❌ No se recibió id_carrito del backend');
    }

    return idCompra;
  }

  return null;
}
