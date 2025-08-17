import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credential_provider.dart';
import '../widgets/credential_item.dart';
import '../utils/constant.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CredentialProvider>(context, listen: false)
          .loadFavoriteCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<CredentialProvider>(
        builder: (context, credentialProvider, child) {
          if (credentialProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteCredentials = credentialProvider.favoriteCredentials;

          if (favoriteCredentials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mark credentials as favorites for quick access',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteCredentials.length,
            itemBuilder: (context, index) {
              final credential = favoriteCredentials[index];
              return CredentialItem(
                credential: credential,
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
                onFavoriteToggle: () {
                  credentialProvider.toggleFavorite(
                    credential.id,
                    credential.categoryId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}