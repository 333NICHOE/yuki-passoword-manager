import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../utils/constant.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PinService _pinService = PinService();

  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePinDialog(),
    );
  }

  void _showResetPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
          'Are you sure you want to reset your PIN? You will need to set up a new PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _pinService.resetPin();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/pin-setup',
                  (route) => false,
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Security Section
          _buildSectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change PIN'),
            subtitle: const Text('Update your security PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePinDialog,
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.red),
            title: const Text('Reset PIN', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Reset and set up a new PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showResetPinDialog,
          ),
          
          const Divider(),
          
          // App Info Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(ApplicationConstants.applicationVersion),
          ),
          ListTile(
            leading: const Icon(Icons.apps),
            title: Text(ApplicationConstants.appName),
            subtitle: const Text('Secure password manager'),
          ),
          
          const Divider(),
          
          // Data Section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Storage'),
            subtitle: const Text('Data is stored locally on your device'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Encryption'),
            subtitle: const Text('All data is encrypted and secure'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final PinService _pinService = PinService();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _changePin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _pinService.changePin(
        _oldPinController.text,
        _newPinController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN changed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid current PIN'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change PIN'),
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
    return AlertDialog(
      title: const Text('Change PIN'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _oldPinController,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) {
                if (value == null || value.length != 4) {
                  return 'PIN must be 4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPinController,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) {
                if (value == null || value.length != 4) {
                  return 'PIN must be 4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPinController,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) {
                if (value != _newPinController.text) {
                  return 'PINs do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePin,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change PIN'),
        ),
      ],
    );
  }
}