import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/credential_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class CategoryItem extends StatelessWidget {
  final Category category;

  const CategoryItem({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.folder,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Consumer<CredentialProvider>(
          builder: (context, credentialProvider, child) {
            final credentials = credentialProvider.getCredentialsForCategory(category.id);
            return Text('${credentials.length} credentials');
          },
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Credentials'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Category'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'add_credential',
              child: ListTile(
                leading: Icon(Icons.add),
                title: Text('Add Credential'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Category', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _viewCategory(context),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view':
        _viewCategory(context);
        break;
      case 'edit':
        _editCategory(context);
        break;
      case 'add_credential':
        _addCredential(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _viewCategory(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppConstants.categoryCredentialsRoute,
      arguments: category,
    );
  }

  void _editCategory(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppConstants.editCategoryRoute,
      arguments: category,
    );
  }

  void _addCredential(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppConstants.addCredentialRoute,
      arguments: category.id,
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(AppConstants.confirmDeleteCategory),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context) async {
    try {
      await Provider.of<CategoryProvider>(context, listen: false)
          .deleteCategory(category.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.successCategoryDeleted),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
