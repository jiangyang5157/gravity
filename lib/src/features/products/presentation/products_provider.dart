import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gravity/src/features/products/domain/product.dart';
import 'package:gravity/src/features/products/domain/product_repository.dart';
import '../data/repository_factory_web.dart';
// import '../data/repository_factory.dart'
//     if (dart.library.io) '../data/repository_factory_io.dart'
//     if (dart.library.html) '../data/repository_factory_web.dart';

part 'products_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ProductRepository> productRepository(ProductRepositoryRef ref) {
  return createProductRepository(ref);
}

@riverpod
Stream<List<Product>> products(ProductsRef ref) async* {
  final repository = await ref.watch(productRepositoryProvider.future);
  yield* repository.watchAllProducts();
}

@riverpod
Future<Product?> product(ProductRef ref, int id) async {
  final repository = await ref.watch(productRepositoryProvider.future);
  return repository.getProduct(id);
}
