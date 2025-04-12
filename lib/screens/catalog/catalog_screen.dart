import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../config/api_config.dart'; // para usar baseUrl centralizado

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> allProducts = [];
  String searchQuery = "";
  String selectedCategory = 'Todos';
  bool sortByPriceAsc = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('$baseUrl/catalogo'); //  baseUrl importado

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allProducts =
              data.map<Product>((item) => Product.fromJson(item)).toList();
        });
      } else {
        throw Exception('No se pudo cargar el catálogo');
      }
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    }
  }

  List<String> get categories {
    return [
      'Todos',
      ...{for (var p in allProducts) p.category}
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    List<Product> filtered = allProducts
        .where((product) =>
            (selectedCategory == 'Todos' ||
                product.category == selectedCategory) &&
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    filtered.sort((a, b) => sortByPriceAsc
        ? a.price.compareTo(b.price)
        : b.price.compareTo(a.price));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.items.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.mic),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar producto...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
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
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                        items: categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () =>
                          setState(() => sortByPriceAsc = !sortByPriceAsc),
                      icon: Icon(sortByPriceAsc
                          ? Icons.arrow_upward
                          : Icons.arrow_downward),
                      tooltip: 'Ordenar por precio',
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final product = filtered[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.network(
                            product.imageUrl,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Categoría: ${product.category}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () {
                              cart.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Producto agregado al carrito'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
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
