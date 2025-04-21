// lib/utils/api_config.dart

const String apiBaseURL = "http://192.168.0.12:5000";

class ApiConfig {
  // 🟢 URL del backend desplegado en Render
  static const String baseUrl = 'https://smartcart-backend-klyi.onrender.com';

  // Endpoints
  static String catalogoUrl() => '$baseUrl/catalogo';
  static String carritoCrearUrl() => '$baseUrl/carrito/crear';
  static String loginUrl() => '$baseUrl/login';
  static String confirmarVenta(int idCarrito) =>
      '$baseUrl/ventas/confirmar/$idCarrito';
  static String calificarUrl() => '$baseUrl/calificaciones';
  static String tokenVisitanteUrl() => '$baseUrl/token/visitante';
  static String comprasUrl(int idCompra) => '$baseUrl/compras/$idCompra';
  static String imagenUrl(String? imagen) =>
      (imagen != null && imagen.isNotEmpty)
          ? "$baseUrl/uploads/\$imagen"
          : "https://via.placeholder.com/60";
}

Map<String, String> headersWithToken(String token) => {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
