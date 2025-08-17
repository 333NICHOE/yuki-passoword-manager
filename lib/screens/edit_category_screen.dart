import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../utils/constant.dart';
import '../utils/theme.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({super.key});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Category? _originalCategory;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_originalCategory == null) {
      _originalCategory = ModalRoute.of(context)?.settings.arguments as Category?;
      if (_originalCategory != null) {
        _nameController.text = _originalCategory!.name;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate() || _originalCategory == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCategory = _originalCategory!.copyWith(
        name: _nameController.text.trim(),
      );

      await Provider.of<CategoryProvider>(context, listen: false)
          .updateCategory(updatedCategory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ApplicationConstants.successCategoryEdited),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ApplicationConstants.errorSavingData),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_originalCategory == null) {
      return const Scaffold(
        body: Center(
          child: Text('Category not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCategory,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Category Details',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return ApplicationConstants.requiredField;
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Changing the category name will update it for all associated credentials.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}