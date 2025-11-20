import 'package:rxdart/rxdart.dart';
import 'package:gravity/src/features/products/domain/product.dart';
import 'package:gravity/src/features/products/domain/product_repository.dart';

class InMemoryProductRepository implements ProductRepository {
  final List<Product> _products = [];
  final _productsSubject = BehaviorSubject<List<Product>>.seeded([]);

  InMemoryProductRepository() {
    // Seed with some initial data for Web
    _seedData();
  }

  void _seedData() {
    final initialProducts = [
      Product(
        id: 1,
        title: 'Neon Cyber Headphones',
        description:
            'High-fidelity audio with a cyberpunk aesthetic. Noise cancelling and RGB lighting.',
        price: 299.99,
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=1000&q=80',
        category: 'Electronics',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 2,
        title: 'Holographic Smart Watch',
        description: 'Next-gen wearable with holographic display projection.',
        price: 499.00,
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1000&q=80',
        category: 'Wearables',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 3,
        title: 'Quantum Running Shoes',
        description:
            'Lightweight, durable, and stylish. Designed for zero-gravity running.',
        price: 159.50,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1000&q=80',
        category: 'Fashion',
        createdAt: DateTime.now(),
      ),
      Product(
        id: 4,
        title: 'Retro Camera X1',
        description: 'Vintage design with modern 50MP sensor.',
        price: 899.00,
        imageUrl:
            'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1000&q=80',
        category: 'Photography',
        createdAt: DateTime.now(),
      ),
    ];
    _products.addAll(initialProducts);
    _productsSubject.add(_products);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    return _products;
  }

  @override
  Future<Product?> getProduct(int id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    final newId =
        (_products.isNotEmpty
            ? _products.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b)
            : 0) +
        1;
    final newProduct = product.copyWith(id: newId);
    _products.add(newProduct);
    _productsSubject.add(_products);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _productsSubject.add(_products);
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
    _productsSubject.add(_products);
  }

  @override
  Stream<List<Product>> watchAllProducts() {
    return _productsSubject.stream;
  }
}
