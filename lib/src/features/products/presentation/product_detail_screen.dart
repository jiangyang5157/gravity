import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import 'products_provider.dart';
import 'package:gravity/src/features/auth/presentation/auth_provider.dart';
import 'package:gravity/src/features/cart/presentation/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;

  void _nextImage(int length) {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % length;
    });
  }

  void _prevImage(int length) {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + length) % length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(
      productProvider(int.parse(widget.productId)),
    );

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          final hasMultipleImages = product.imageUrls.length > 1;

          // Safety check for image index
          if (_currentImageIndex >= product.imageUrls.length) {
            _currentImageIndex = 0;
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 0, // Reduced height since image is moved
                pinned: true,
                actions: [
                  if (ref.watch(authControllerProvider)?.isAdmin == true) ...[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await context.push('/edit/${product.id}');
                        // Refresh is handled by invalidation in EditProductScreen
                      },
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
                              .read(productRepositoryProvider.future)
                              .then((repo) => repo.deleteProduct(product.id!));
                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Images (Carousel) - Now at the top
                      SizedBox(
                        height: 400,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: 'product-${product.id}',
                              child: Image.network(
                                product.imageUrls.isNotEmpty
                                    ? product.imageUrls[_currentImageIndex]
                                    : '',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            if (hasMultipleImages) ...[
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton.filledTonal(
                                    onPressed: () =>
                                        _prevImage(product.imageUrls.length),
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton.filledTonal(
                                    onPressed: () =>
                                        _nextImage(product.imageUrls.length),
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: product.imageUrls
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _currentImageIndex = entry.key;
                                            });
                                          },
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  _currentImageIndex ==
                                                      entry.key
                                                  ? Theme.of(
                                                      context,
                                                    ).primaryColor
                                                  : Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.5),
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Gap(24),

                      // 2. Title and Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  product.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const Gap(4),
                                SelectableText(
                                  'ID: #${product.id} • Modified: ${product.lastModifiedDate.toString().split('.')[0]}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                          SelectableText(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Gap(16),

                      // 3. Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.tags
                            .map(
                              (tag) => Chip(
                                label: SelectableText(tag),
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                labelStyle: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const Gap(24),

                      // 4. Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(8),
                      SelectableText(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      if (ref.watch(authControllerProvider)?.isAdmin !=
                          true) ...[
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
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
