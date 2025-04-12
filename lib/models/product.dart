class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['nombre'],
      price: (json['precio'] as num).toDouble(),
      category: json['categoria'],
      imageUrl: json['imagen'] != null && json['imagen'].toString().isNotEmpty
          ? json['imagen']
          : 'https://cdn-icons-png.flaticon.com/512/679/679720.png', // imagen por defecto
    );
  }
}
