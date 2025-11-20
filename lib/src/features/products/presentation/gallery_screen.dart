import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:gravity/src/features/auth/presentation/auth_provider.dart';
import 'package:gravity/src/features/cart/presentation/cart_provider.dart';
import 'products_provider.dart';
import 'widgets/product_card.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Product Gallery'),
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, or tags...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
          ),

          productsAsync.when(
            data: (products) {
              var filteredProducts = products;
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                final searchTags = query
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                filteredProducts = products.where((product) {
                  final titleMatch = product.title.toLowerCase().contains(
                    query,
                  );
                  final idMatch = product.id.toString().contains(query);
                  final tagsMatch =
                      searchTags.isNotEmpty &&
                      searchTags.any(
                        (tag) => product.tags.any(
                          (pTag) => pTag.toLowerCase().contains(tag),
                        ),
                      );
                  return titleMatch || idMatch || tagsMatch;
                }).toList();
              }

              // Sort by lastModifiedDate descending
              filteredProducts.sort(
                (a, b) => b.lastModifiedDate.compareTo(a.lastModifiedDate),
              );

              if (filteredProducts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No products found')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(product: product)
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideY(begin: 0.1, end: 0);
                  }, childCount: filteredProducts.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }
}
