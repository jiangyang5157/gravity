import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'memory/in_memory_product_repository.dart';
import 'package:gravity/src/features/products/domain/product_repository.dart';

Future<ProductRepository> createProductRepository(Ref ref) async {
  return InMemoryProductRepository();
}
