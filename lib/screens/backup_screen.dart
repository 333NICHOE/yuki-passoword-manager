import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/backup_service.dart';
import '../utils/constants.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  final TextEditingController _restoreController = TextEditingController();
  Map<String, dynamic>? _backupInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }

  @override
  void dispose() {
    _restoreController.dispose();
    super.dispose();
  }

  Future<void> _loadBackupInfo() async {
    try {
      final info = await _backupService.getBackupInfo();
      setState(() {
        _backupInfo = info;
      });
    } catch (e) {
      _showError('Failed to load backup info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_backupInfo != null) ...[
                      Text('Categories: ${_backupInfo!['categories']}'),
                      Text('Credentials: ${_backupInfo!['credentials']}'),
                      Text('Last Backup: ${_backupInfo!['lastBackup']}'),
                    ] else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Backup Section
            Text(
              'Create Backup',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createBackupToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy to Clipboard'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createBackupToFile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save to File'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Restore Section
            Text(
              'Restore from Backup',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _restoreController,
              decoration: const InputDecoration(
                labelText: 'Paste backup data here',
                border: OutlineInputBorder(),
                hintText: 'Paste your backup JSON data...',
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _restoreFromBackup,
                icon: const Icon(Icons.restore),
                label: const Text('Restore Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Restoring will replace all current data. Make sure to backup first!',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackupToClipboard() async {
    setState(() => _isLoading = true);
    try {
      await _backupService.copyBackupToClipboard();
      _showSuccess('Backup copied to clipboard!');
    } catch (e) {
      _showError('Failed to create backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackupToFile() async {
    setState(() => _isLoading = true);
    try {
      final filePath = await _backupService.saveBackupToFile();
      _showSuccess('Backup saved to: $filePath');
    } catch (e) {
      _showError('Failed to save backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromBackup() async {
    if (_restoreController.text.trim().isEmpty) {
      _showError('Please paste backup data first');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await _backupService.restoreFromBackup(_restoreController.text.trim());
      _showSuccess('Data restored successfully!');
      _restoreController.clear();
      _loadBackupInfo();
    } catch (e) {
      _showError('Failed to restore backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: const Text(
          'This will replace all your current passwords with the backup data. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Restore'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
