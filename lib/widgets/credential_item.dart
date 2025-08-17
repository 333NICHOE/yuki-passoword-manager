import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/credential.dart';
import '../utils/constant.dart';
import '../utils/theme.dart';

class CredentialItem extends StatelessWidget {
  final Credential credential;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const CredentialItem({
    super.key,
    required this.credential,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
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
            child: _getServiceIcon(credential.website),
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
            const SizedBox(height: 4),
            Text(
              '••••••••',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                credential.favorite ? Icons.favorite : Icons.favorite_border,
                color: credential.favorite ? Colors.red : Colors.grey[400],
              ),
              onPressed: onFavoriteToggle,
            ),
            IconButton(
              icon: Icon(
                Icons.copy,
                color: Colors.grey[400],
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: credential.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(ApplicationConstants.successPasswordCopied),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _getServiceIcon(String website) {
    final lowercaseWebsite = website.toLowerCase();
    
    if (lowercaseWebsite.contains('google')) {
      return const Icon(Icons.g_mobiledata, color: Colors.red, size: 24);
    } else if (lowercaseWebsite.contains('netflix')) {
      return const Icon(Icons.movie, color: Colors.red, size: 24);
    } else if (lowercaseWebsite.contains('twitter') || lowercaseWebsite.contains('x.com')) {
      return const Icon(Icons.alternate_email, color: Colors.blue, size: 24);
    } else if (lowercaseWebsite.contains('facebook')) {
      return const Icon(Icons.facebook, color: Colors.blue, size: 24);
    } else if (lowercaseWebsite.contains('instagram')) {
      return const Icon(Icons.camera_alt, color: Colors.purple, size: 24);
    } else if (lowercaseWebsite.contains('bank') || lowercaseWebsite.contains('finance')) {
      return const Icon(Icons.account_balance, color: Colors.green, size: 24);
    } else if (lowercaseWebsite.contains('shop') || lowercaseWebsite.contains('amazon') || lowercaseWebsite.contains('ebay')) {
      return const Icon(Icons.shopping_cart, color: Colors.orange, size: 24);
    } else {
      return Text(
        website.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      );
    }
  }
}