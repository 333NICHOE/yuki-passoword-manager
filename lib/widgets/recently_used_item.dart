import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/credential.dart';
import '../utils/constant.dart';

class RecentlyUsedItem extends StatelessWidget {
  final Credential credential;
  final VoidCallback onTap;

  const RecentlyUsedItem({
    Key? key,
    required this.credential,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _getServiceLogo(credential.website),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    credential.website,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    credential.username,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.copy_rounded,
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
      ),
    );
  }

  Widget _getServiceLogo(String website) {
    final lowercaseWebsite = website.toLowerCase();
    
    if (lowercaseWebsite.contains('google')) {
      return const Icon(Icons.g_mobiledata, size: 30, color: Colors.red);
    } else if (lowercaseWebsite.contains('netflix')) {
      return const Icon(Icons.movie, size: 30, color: Colors.red);
    } else if (lowercaseWebsite.contains('twitter')) {
      return const Icon(Icons.alternate_email, size: 30, color: Colors.blue);
    } else if (lowercaseWebsite.contains('dribbble')) {
      return const Icon(Icons.sports_basketball, size: 30, color: Colors.pink);
    } else {
      return Text(
        website.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
