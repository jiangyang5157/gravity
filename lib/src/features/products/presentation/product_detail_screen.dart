import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import 'products_provider.dart';

import 'package:gravity/src/features/auth/presentation/auth_provider.dart';
import 'package:gravity/src/features/cart/presentation/cart_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(int.parse(productId)));
    final isAdmin = ref.watch(authControllerProvider)?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/edit/$productId');
              },
              tooltip: 'Edit Product',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Product'),
                    content: const Text(
                      'Are you sure you want to delete this product?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(productRepositoryProvider)
                      .value
                      ?.deleteProduct(int.parse(productId));
                  if (context.mounted) {
                    context.pop(); // Assuming context.pop is available
                  }
                }
              },
              tooltip: 'Delete Product',
            ),
          ],
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'product-${product.id}',
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: kIsWeb
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                ),
                          )
                        : (product.imageUrl.startsWith('http')
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                )
                              : Image.file(
                                  File(product.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Chip(
                        label: Text(product.category),
                        backgroundColor: AppColors.primary.withOpacity(
                          0.1,
                        ), // Corrected from withValues
                        labelStyle: const TextStyle(color: AppColors.primary),
                      ),
                      const Gap(24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (!isAdmin) ...[
                        const Gap(48),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.title} added to cart',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text('Add to Cart'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
