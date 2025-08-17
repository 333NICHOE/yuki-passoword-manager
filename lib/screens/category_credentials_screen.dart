import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/credential.dart';
import '../providers/credential_provider.dart';
import '../widgets/credential_item.dart';
import '../utils/constant.dart';

class CategoryCredentialsScreen extends StatefulWidget {
  const CategoryCredentialsScreen({super.key});

  @override
  State<CategoryCredentialsScreen> createState() => _CategoryCredentialsScreenState();
}

class _CategoryCredentialsScreenState extends State<CategoryCredentialsScreen> {
  Category? category;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (category == null) {
      category = ModalRoute.of(context)?.settings.arguments as Category?;
      if (category != null) {
        Provider.of<CredentialProvider>(context, listen: false)
            .loadCredentialsForCategory(category!.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return const Scaffold(
        body: Center(
          child: Text('Category not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, ApplicationConstants.addCredentialRoute);
            },
          ),
        ],
      ),
      body: Consumer<CredentialProvider>(
        builder: (context, credentialProvider, child) {
          if (credentialProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final credentials = credentialProvider.getCredentialsForCategory(category!.id);

          if (credentials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.password,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No credentials found',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first credential for this category',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, ApplicationConstants.addCredentialRoute);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Credential'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: credentials.length,
            itemBuilder: (context, index) {
              final credential = credentials[index];
              return CredentialItem(
                credential: credential,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ApplicationConstants.viewCredentialRoute,
                    arguments: {
                      'credential': credential,
                      'categoryId': category!.id,
                    },
                  );
                },
                onFavoriteToggle: () {
                  credentialProvider.toggleFavorite(credential.id, category!.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}