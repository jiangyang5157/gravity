import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:gravity/src/features/products/domain/product.dart';
import 'package:gravity/src/features/products/presentation/products_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        title: _titleController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        imageUrl: _imageController.text,
        category: _categoryController.text,
        createdAt: DateTime.now(),
      );

      final repo = await ref.read(productRepositoryProvider.future);
      await repo.addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(v) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL or Path',
                  hintText: 'https://... or /path/to/image.jpg',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(32),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
