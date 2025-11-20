import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:gravity/src/core/theme/app_colors.dart';
import 'package:gravity/src/features/products/domain/product.dart';
import 'package:gravity/src/features/cart/presentation/cart_provider.dart';
import 'package:gravity/src/features/auth/presentation/auth_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // Image Section
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Hero(
                    tag: 'product_${widget.product.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(widget.product.imageUrl),
                        // Gradient Overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content Section
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
                            if (isAdmin) return const SizedBox.shrink();

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

  Widget _buildImage(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    } else if (kIsWeb) {
      // Web doesn't support File(path)
      return const Center(child: Icon(Icons.image_not_supported));
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }
  }
}
