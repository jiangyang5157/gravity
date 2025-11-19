import 'product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<Product?> getProduct(int id);
  Future<void> addProduct(Product product);
  Future<void> deleteProduct(int id);
  Stream<List<Product>> watchAllProducts();
}
