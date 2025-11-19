class Product {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final DateTime createdAt;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
  });

  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
