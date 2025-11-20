class Product {
  final int? id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime lastModifiedDate;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.tags,
    required this.createdAt,
    required this.lastModifiedDate,
  });

  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastModifiedDate,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
    );
  }
}
