import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/credential.dart';
import '../providers/credential_provider.dart';
import '../utils/constant.dart';
import '../utils/theme.dart';

class ViewCredentialScreen extends StatefulWidget {
  const ViewCredentialScreen({super.key});

  @override
  State<ViewCredentialScreen> createState() => _ViewCredentialScreenState();
}

class _ViewCredentialScreenState extends State<ViewCredentialScreen> {
  Credential? credential;
  String? categoryId;
  bool _isPasswordVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (credential == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        credential = args['credential'] as Credential?;
        categoryId = args['categoryId'] as String?;
        
        // Mark as recently used
        if (credential != null && categoryId != null) {
          Provider.of<CredentialProvider>(context, listen: false)
              .markAsRecentlyUsed(credential!.id, categoryId!);
        }
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite() {
    if (credential != null && categoryId != null) {
      Provider.of<CredentialProvider>(context, listen: false)
          .toggleFavorite(credential!.id, categoryId!);
      
      setState(() {
        credential = credential!.copyWith(favorite: !credential!.favorite);
      });
    }
  }

  void _editCredential() {
    Navigator.pushNamed(
      context,
      ApplicationConstants.editCredentialRoute,
      arguments: {
        'credential': credential,
        'categoryId': categoryId,
      },
    );
  }

  void _deleteCredential() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credential'),
        content: Text(ApplicationConstants.confirmDeleteCredential),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (credential != null && categoryId != null) {
                await Provider.of<CredentialProvider>(context, listen: false)
                    .deleteCredential(credential!.id, categoryId!);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(ApplicationConstants.successCredentialDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (credential == null) {
      return const Scaffold(
        body: Center(
          child: Text('Credential not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(credential!.website),
        actions: [
          IconButton(
            icon: Icon(
              credential!.favorite ? Icons.favorite : Icons.favorite_border,
              color: credential!.favorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editCredential();
                  break;
                case 'delete':
                  _deleteCredential();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Website/Service Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          credential!.website.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            credential!.website,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last used: ${_formatDate(credential!.lastUsed)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Username Field
            _buildInfoCard(
              'Username/Email',
              credential!.username,
              Icons.person,
              () => _copyToClipboard(credential!.username, 'Username'),
            ),
            const SizedBox(height: 16),
            
            // Password Field
            _buildInfoCard(
              'Password',
              _isPasswordVisible ? credential!.password : '••••••••••••',
              Icons.lock,
              () => _copyToClipboard(credential!.password, 'Password'),
              trailing: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(credential!.username, 'Username'),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Username'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(credential!.password, 'Password'),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Password'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    VoidCallback onCopy, {
    Widget? trailing,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: onCopy,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}