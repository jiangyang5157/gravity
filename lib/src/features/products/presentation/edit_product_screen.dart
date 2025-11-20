import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:gravity/src/features/products/domain/product.dart';
import 'products_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  String _selectedCategory = 'Electronics';
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _initializeControllers(Product product) {
    if (_isInitialized) return;
    _titleController.text = product.title;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _imageUrlController.text = product.imageUrl;
    _selectedCategory = product.category;
    _isInitialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = await ref.read(
        productProvider(int.parse(widget.productId)).future,
      );

      if (product == null) throw Exception('Product not found');

      final updatedProduct = product.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
        category: _selectedCategory,
      );

      await ref
          .read(productRepositoryProvider)
          .value
          ?.updateProduct(updatedProduct);

      ref.invalidate(productProvider(int.parse(widget.productId)));

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(
      productProvider(int.parse(widget.productId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }
          _initializeControllers(product);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Please enter title' : null,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Please enter description' : null,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter price';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const Gap(16),
                  TextFormField(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Please enter category' : null,
                    onChanged: (v) => _selectedCategory = v,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Please enter image URL' : null,
                  ),
                  const Gap(32),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Update Product'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
