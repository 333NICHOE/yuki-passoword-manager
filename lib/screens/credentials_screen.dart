import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credential_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/credential_item.dart';
import '../utils/constants.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({Key? key}) : super(key: key);

  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      _loadCredentials();
    });
  }

  void _loadCredentials() {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final credentialProvider = Provider.of<CredentialProvider>(context, listen: false);
    
    for (var category in categoryProvider.categories) {
      credentialProvider.loadCredentialsForCategory(category.id);
    }
    
    if (_selectedFilter == 'favorites') {
      credentialProvider.loadFavoriteCredentials();
    } else if (_selectedFilter == 'recent') {
      credentialProvider.loadRecentlyUsedCredentials();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Credentials'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
              _loadCredentials();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Credentials'),
              ),
              const PopupMenuItem(
                value: 'favorites',
                child: Text('Favorites Only'),
              ),
              const PopupMenuItem(
                value: 'recent',
                child: Text('Recently Used'),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.searchRoute);
            },
          ),
        ],
      ),
      body: Consumer2<CategoryProvider, CredentialProvider>(
        builder: (context, categoryProvider, credentialProvider, child) {
          if (categoryProvider.isLoading || credentialProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Widget> credentialWidgets = [];

          if (_selectedFilter == 'favorites') {
            final favorites = credentialProvider.favoriteCredentials;
            for (var credential in favorites) {
              credentialWidgets.add(
                CredentialItem(
                  credential: credential,
                  categoryId: credential.categoryId,
                ),
              );
            }
          } else if (_selectedFilter == 'recent') {
            final recent = credentialProvider.recentlyUsedCredentials;
            for (var credential in recent) {
              credentialWidgets.add(
                CredentialItem(
                  credential: credential,
                  categoryId: credential.categoryId,
                ),
              );
            }
          } else {
            // All credentials grouped by category
            for (var category in categoryProvider.categories) {
              final credentials = credentialProvider.getCredentialsForCategory(category.id);
              
              if (credentials.isNotEmpty) {
                credentialWidgets.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
                
                for (var credential in credentials) {
                  credentialWidgets.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CredentialItem(
                        credential: credential,
                        categoryId: category.id,
                      ),
                    ),
                  );
                }
              }
            }
          }

          if (credentialWidgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _getEmptyMessage(),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppConstants.addCredentialRoute);
                    },
                    child: const Text('Add First Credential'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: credentialWidgets,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppConstants.addCredentialRoute);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'favorites':
        return 'No favorite credentials';
      case 'recent':
        return 'No recently used credentials';
      default:
        return 'No credentials yet';
    }
  }
}
