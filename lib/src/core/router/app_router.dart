import 'package:go_router/go_router.dart';
import 'package:gravity/src/features/auth/presentation/auth_provider.dart';
import 'package:gravity/src/features/auth/presentation/login_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/products/presentation/add_product_screen.dart';
import '../../features/products/presentation/edit_product_screen.dart';
import '../../features/products/presentation/gallery_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoggingIn = state.uri.path == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      if (state.uri.path.startsWith('/add') && authState?.isAdmin != true) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => const GalleryScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailScreen(productId: id);
            },
          ),
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddProductScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EditProductScreen(productId: id);
            },
          ),
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
        ],
      ),
    ],
  );
}
