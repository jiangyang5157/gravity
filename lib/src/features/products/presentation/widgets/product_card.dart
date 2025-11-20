import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:gravity/src/core/theme/app_colors.dart';
import 'package:gravity/src/features/products/domain/product.dart';
import 'package:gravity/src/features/products/presentation/products_provider.dart';
import 'package:gravity/src/features/cart/presentation/cart_provider.dart';
import 'package:gravity/src/features/auth/presentation/auth_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _currentImageIndex = 0;
  bool _isHovered = false;

  void _nextImage() {
    setState(() {
      _currentImageIndex =
          (_currentImageIndex + 1) % widget.product.imageUrls.length;
    });
  }

  void _prevImage() {
    setState(() {
      _currentImageIndex =
          (_currentImageIndex - 1 + widget.product.imageUrls.length) %
          widget.product.imageUrls.length;
    });
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.imageUrls.length != oldWidget.product.imageUrls.length) {
      if (_currentImageIndex >= widget.product.imageUrls.length) {
        _currentImageIndex = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasMultipleImages = widget.product.imageUrls.length > 1;

    // Ensure index is valid (safety check)
    if (_currentImageIndex >= widget.product.imageUrls.length &&
        widget.product.imageUrls.isNotEmpty) {
      _currentImageIndex = 0;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/product/${widget.product.id}'),
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 10 : 4),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(_isHovered ? 0.2 : 0.05)
                  : Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-${widget.product.id}',
                      child: Image.network(
                        widget.product.imageUrls.isNotEmpty
                            ? widget.product.imageUrls[_currentImageIndex]
                            : '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (hasMultipleImages && _isHovered) ...[
                      Positioned(
                        left: 4,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton.filledTonal(
                            onPressed: () {
                              // Prevent card tap
                              _prevImage();
                            },
                            icon: const Icon(Icons.chevron_left),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton.filledTonal(
                            onPressed: _nextImage,
                            icon: const Icon(Icons.chevron_right),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                    if (hasMultipleImages)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: widget.product.imageUrls
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
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == entry.key
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.secondaryLight
                                    : AppColors.secondaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final isAdmin =
                                ref.watch(authControllerProvider)?.isAdmin ??
                                false;

                            if (isAdmin) {
                              return IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
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
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
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
                                        .then(
                                          (repo) => repo.deleteProduct(
                                            widget.product.id!,
                                          ),
                                        );
                                    // Refresh handled by provider invalidation usually,
                                    // but here we might need to trigger a refresh if the list doesn't auto-update.
                                    // Assuming the list provider watches the repo or we invalidate it.
                                    ref.invalidate(productsProvider);
                                  }
                                },
                                tooltip: 'Delete Product',
                              );
                            }

                            return IconButton(
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                size: 20,
                              ),
                              onPressed: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .addToCart(widget.product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.product.title} added to cart',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              tooltip: 'Add to Cart',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
