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
    final now = DateTime.now();
    final initialProducts = [
      Product(
        id: 1,
        title: 'Neon Cyber Headphones',
        description:
            'High-fidelity audio with a cyberpunk aesthetic. Noise cancelling and RGB lighting.',
        price: 299.99,
        imageUrls: [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&w=800&q=80',
        ],
        tags: ['Electronics', 'Audio', 'Cyberpunk'],
        createdAt: now,
        lastModifiedDate: now,
      ),
      Product(
        id: 2,
        title: 'Holographic Smart Watch',
        description: 'Next-gen wearable with holographic display projection.',
        price: 499.00,
        imageUrls: [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
        ],
        tags: ['Wearables', 'Tech', 'Future'],
        createdAt: now,
        lastModifiedDate: now,
      ),
      Product(
        id: 3,
        title: 'Quantum Running Shoes',
        description:
            'Lightweight, durable, and stylish. Designed for zero-gravity running.',
        price: 159.50,
        imageUrls: [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
        ],
        tags: ['Fashion', 'Sports', 'Shoes'],
        createdAt: now,
        lastModifiedDate: now,
      ),
      Product(
        id: 4,
        title: 'Retro Camera X1',
        description: 'Vintage design with modern 50MP sensor.',
        price: 899.00,
        imageUrls: [
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
        ],
        tags: ['Photography', 'Retro', 'Camera'],
        createdAt: now,
        lastModifiedDate: now,
      ),
    ];
    final newProducts = [
      Product(
        id: 5,
        title: 'Levitating Bonsai Pot',
        description:
            'Zero-gravity plant pot that rotates smoothly. Perfect for your zen corner.',
        price: 129.99,
        imageUrls: [
          'https://images.unsplash.com/photo-1613143916298-9c4d5a141064?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1512428908174-cc5a6398d601?auto=format&fit=crop&w=800&q=80',
        ],
        tags: ['Home', 'Decor', 'Nature'],
        createdAt: now,
        lastModifiedDate: now,
      ),
      Product(
        id: 6,
        title: 'Neural Interface Headset',
        description:
            'Control your devices with your mind. The future of gaming and productivity.',
        price: 899.99,
        imageUrls: [
          'https://images.unsplash.com/photo-1592478411213-61535fdd861d?auto=format&fit=crop&w=800&q=80',
        ],
        tags: ['Tech', 'Gaming', 'Future'],
        createdAt: now,
        lastModifiedDate: now,
      ),
      Product(
        id: 7,
        title: 'Smart Coffee Mug',
        description:
            'Keeps your coffee at the perfect temperature. Control via app.',
        price: 89.50,
        imageUrls: [
          'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=800&q=80',
        ],
        tags: ['Home', 'Kitchen', 'Smart'],
        createdAt: now,
        lastModifiedDate: now,
      ),
    ];
    _products.addAll(initialProducts);
    _products.addAll(newProducts);
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
    final now = DateTime.now();
    final newProduct = product.copyWith(
      id: newId,
      createdAt: now,
      lastModifiedDate: now,
    );
    _products.add(newProduct);
    _productsSubject.add(_products);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product.copyWith(lastModifiedDate: DateTime.now());
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
