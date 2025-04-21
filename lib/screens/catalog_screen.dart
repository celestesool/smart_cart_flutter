// 📁 lib/screens/catalogo_screen.dart

// ignore_for_file: avoid_print, unused_element, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/cart_service.dart';
import '../models/product.dart';
import '../widgets/mic_button.dart'; // 👈 micrófono en todas las pantallas

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  List productos = [];
  String searchQuery = "";
  String selectedCategory = "Todos";
  bool sortByPriceAsc = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(
        "🔄 Volviendo al catálogo: verificando si hay que crear un nuevo carrito...");

    verificarOCrearCarrito();
    // ✅ Esto recarga los productos siempre que se vuelve a esta pantalla
  }

  Future<void> cargarProductos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('http://192.168.0.12:5000/catalogo');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print("📡 Estado HTTP: ${response.statusCode}");
      print("📦 BODY crudo: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          productos.clear();
          productos = data['productos'];
        });
      } else {
        print("❌ Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error de red: $e");
    }
  }

  Future<void> verificarOCrearCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('http://192.168.0.12:5000/carrito/crear');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 409) {
        final data = json.decode(response.body);
        final idCarrito = data['id_carrito'];
        print("🛒 Carrito activo ID: $idCarrito");
        await prefs.setInt('id_carrito', idCarrito);
      } else {
        print("❌ No se pudo crear/verificar carrito (${response.statusCode})");
      }
    } catch (e) {
      print("❌ Error al verificar o crear carrito: $e");
    }
  }

  void _verificarRecargaDesdeArgumentos() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['desde_calificar'] == true) {
      print("🔁 Volviendo desde calificación → recargando productos");
      cargarProductos();

      // 🟢 Mensaje visual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gracias por tu calificación 😊")));
      });
    }
  }

  List<String> get categories {
    return [
      'Todos',
      ...{for (var p in productos) p['categoria'] ?? ''}
    ];
  }

  @override
  Widget build(BuildContext context) {
    List filtered = productos
        .where((p) =>
            (selectedCategory == 'Todos' ||
                p['categoria'] == selectedCategory) &&
            p['nombre'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    filtered.sort((a, b) => sortByPriceAsc
        ? a['precio'].compareTo(b['precio'])
        : b['precio'].compareTo(a['precio']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Salir',
            onPressed: () => cerrarSesion(context),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Ver carrito',
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      floatingActionButton: const MicButton(), // 👈 reemplaza el botón viejo
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedCategory = value);
                          }
                        },
                        items: categories
                            .map((cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(sortByPriceAsc
                          ? Icons.arrow_upward
                          : Icons.arrow_downward),
                      tooltip: 'Ordenar por precio',
                      onPressed: () =>
                          setState(() => sortByPriceAsc = !sortByPriceAsc),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final p = filtered[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.network(
                            (p['imagen'] != null &&
                                    p['imagen'].toString().isNotEmpty)
                                ? "http://192.168.0.12:5000/uploads/${p['imagen']}"
                                : "https://via.placeholder.com/60",
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image,
                                    size: 50, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p['nombre'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Categoría: ${p['categoria']}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bs ${p['precio'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF43A047),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height:
                                8), // ✅ En vez de Spacer, que causa conflicto visual
                        IconButton(
                          alignment: Alignment.bottomRight,
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () async {
                            final agregado = await agregarProductoAlCarrito(
                              Product(
                                id: p['id'],
                                nombre: p['nombre'],
                                descripcion: p['descripcion'],
                                precio: p['precio'].toDouble(),
                                stock: p['stock'],
                                categoria: p['categoria'],
                                imagen: p['imagen'],
                              ),
                              1,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  agregado
                                      ? '✅ Producto agregado al carrito'
                                      : '❌ Error al agregar producto',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                behavior: SnackBarBehavior
                                    .floating, // opcional para evitar solapamiento
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Cerrar sesión
Future<void> cerrarSesion(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
}
