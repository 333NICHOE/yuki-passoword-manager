import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credential_provider.dart';
import '../models/credential.dart';
import '../utils/constant.dart';
import '../utils/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    Provider.of<CredentialProvider>(context, listen: false)
        .searchCredentials(query);
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<CredentialProvider>(context, listen: false)
        .clearSearchResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: 'Search passwords...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: Consumer<CredentialProvider>(
        builder: (context, credentialProvider, child) {
          if (credentialProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final searchResults = credentialProvider.searchResults;

          if (_searchController.text.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search your passwords',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter a website, username, or category name',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final result = searchResults[index];
              final credential = Credential(
                id: result['id'],
                categoryId: result['category_id'],
                website: result['website'],
                username: result['username'],
                password: result['password'],
                favorite: result['favorite'] == 1,
                lastUsed: result['last_used'],
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        credential.website.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    credential.website,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        credential.username,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${result['category_name']}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    credential.favorite ? Icons.favorite : Icons.favorite_border,
                    color: credential.favorite ? Colors.red : Colors.grey[400],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ApplicationConstants.viewCredentialRoute,
                      arguments: {
                        'credential': credential,
                        'categoryId': credential.categoryId,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}