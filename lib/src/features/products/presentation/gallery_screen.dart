import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:gravity/src/features/auth/presentation/auth_provider.dart';
import 'package:gravity/src/features/cart/presentation/cart_provider.dart';
import 'products_provider.dart';
import 'widgets/product_card.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Gravity.',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
            actions: [
              if (ref.watch(authControllerProvider)?.isAdmin == true)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => context.go('/add'),
                  tooltip: 'Add Product',
                ),
              Consumer(
                builder: (context, ref, child) {
                  final cartCount = ref.watch(cartItemCountProvider);
                  final isAdmin =
                      ref.watch(authControllerProvider)?.isAdmin ?? false;

                  if (isAdmin) return const SizedBox.shrink();

                  return IconButton(
                    icon: Badge(
                      label: Text('$cartCount'),
                      isLabelVisible: cartCount > 0,
                      child: const Icon(Icons.shopping_cart),
                    ),
                    onPressed: () => context.push('/cart'),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                tooltip: 'Logout',
              ),
              const Gap(8),
            ],
            floating: true,
            pinned: true,
            expandedHeight: 120,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const Gap(16),
                          Text(
                            'No products found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Gap(16),
                          FilledButton.tonal(
                            onPressed: () async {
                              // Quick hack to seed data for the user
                              // In real app, use a proper service
                              // We need to access the repository's isar instance.
                              // Let's make the repository expose it or add a seed method.
                              // For now, let's just rely on the user adding products manually or restart app (if we added auto-seed in main).
                              // Wait, I didn't add auto-seed in main. Let's add a button here that works.
                              // I'll update the repository to expose Isar or add a seed method.
                            },
                            child: const Text('Seed Mock Data'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return ProductCard(product: product)
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideY(begin: 0.1, end: 0);
                  }, childCount: products.length),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
