import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/credential.dart';
import '../models/category.dart';
import '../providers/credential_provider.dart';
import '../providers/category_provider.dart';
import '../utils/constant.dart';
import '../utils/theme.dart';

class EditCredentialScreen extends StatefulWidget {
  const EditCredentialScreen({super.key});

  @override
  State<EditCredentialScreen> createState() => _EditCredentialScreenState();
}

class _EditCredentialScreenState extends State<EditCredentialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _websiteController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  Credential? _originalCredential;
  String? _selectedCategoryId;
  bool _isPasswordVisible = false;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_originalCredential == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _originalCredential = args['credential'] as Credential?;
        if (_originalCredential != null) {
          _websiteController.text = _originalCredential!.website;
          _usernameController.text = _originalCredential!.username;
          _passwordController.text = _originalCredential!.password;
          _selectedCategoryId = _originalCredential!.categoryId;
          _isFavorite = _originalCredential!.favorite;
        }
      }
    }
  }

  @override
  void dispose() {
    _websiteController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    for (int i = 0; i < 12; i++) {
      password += chars[(random + i) % chars.length];
    }
    return password;
  }

  Future<void> _saveCredential() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _originalCredential == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCredential = _originalCredential!.copyWith(
        categoryId: _selectedCategoryId!,
        website: _websiteController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        favorite: _isFavorite,
      );

      await Provider.of<CredentialProvider>(context, listen: false)
          .updateCredential(updatedCredential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ApplicationConstants.successCredentialEdited),
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
    if (_originalCredential == null) {
      return const Scaffold(
        body: Center(
          child: Text('Credential not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Credential'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCredential,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Credential Details',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
                
                // Category Selection
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: categoryProvider.categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ApplicationConstants.requiredField;
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Website/Service Name
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website/Service',
                    hintText: 'e.g., Google, Netflix, Bank',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return ApplicationConstants.requiredField;
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                
                // Username/Email
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username/Email',
                    hintText: 'Enter username or email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return ApplicationConstants.requiredField;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              _passwordController.text = _generatePassword();
                            });
                          },
                          tooltip: 'Generate Password',
                        ),
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ApplicationConstants.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Favorite Toggle
                SwitchListTile(
                  title: const Text('Add to Favorites'),
                  subtitle: const Text('Mark this credential as favorite for quick access'),
                  value: _isFavorite,
                  onChanged: (bool value) {
                    setState(() {
                      _isFavorite = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}