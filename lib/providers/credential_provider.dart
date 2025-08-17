import 'package:flutter/foundation.dart';
import '../models/credential.dart';
import '../services/database_service.dart';

class CredentialProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, List<Credential>> _credentialsByCategory = {};
  List<Credential> _favoriteCredentials = [];
  List<Credential> _recentlyUsedCredentials = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Map<String, List<Credential>> get credentialsByCategory => _credentialsByCategory;
  List<Credential> get favoriteCredentials => _favoriteCredentials;
  List<Credential> get recentlyUsedCredentials => _recentlyUsedCredentials;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  List<Credential> getCredentialsForCategory(String categoryId) {
    return _credentialsByCategory[categoryId] ?? [];
  }

  Future<void> loadCredentialsForCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credentials = await _databaseService.getCredentialsByCategoryId(categoryId);
      _credentialsByCategory[categoryId] = credentials;
    } catch (e) {
      print('Error loading credentials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoriteCredentials() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteCredentials = await _databaseService.getFavoriteCredentials();
    } catch (e) {
      print('Error loading favorite credentials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentlyUsedCredentials() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recentlyUsedCredentials = await _databaseService.getRecentlyUsedCredentials();
    } catch (e) {
      print('Error loading recently used credentials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCredential(Credential credential) async {
    try {
      await _databaseService.insertCredential(credential);
      
      if (_credentialsByCategory.containsKey(credential.categoryId)) {
        _credentialsByCategory[credential.categoryId]!.add(credential);
      } else {
        _credentialsByCategory[credential.categoryId] = [credential];
      }
      
      if (credential.favorite) {
        _favoriteCredentials.add(credential);
      }
      
      _updateRecentlyUsed(credential);
      notifyListeners();
    } catch (e) {
      print('Error adding credential: $e');
      rethrow;
    }
  }

  Future<void> updateCredential(Credential credential) async {
    try {
      await _databaseService.updateCredential(credential);
      
      if (_credentialsByCategory.containsKey(credential.categoryId)) {
        final index = _credentialsByCategory[credential.categoryId]!
            .indexWhere((c) => c.id == credential.id);
        
        if (index != -1) {
          _credentialsByCategory[credential.categoryId]![index] = credential;
        }
      }
      
      final favoriteIndex = _favoriteCredentials.indexWhere((c) => c.id == credential.id);
      if (credential.favorite && favoriteIndex == -1) {
        _favoriteCredentials.add(credential);
      } else if (!credential.favorite && favoriteIndex != -1) {
        _favoriteCredentials.removeAt(favoriteIndex);
      } else if (favoriteIndex != -1) {
        _favoriteCredentials[favoriteIndex] = credential;
      }
      
      _updateRecentlyUsed(credential);
      notifyListeners();
    } catch (e) {
      print('Error updating credential: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id, String categoryId) async {
    try {
      final credential = _credentialsByCategory[categoryId]?.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Credential not found'),
      );
      
      if (credential != null) {
        final updatedCredential = credential.copyWith(favorite: !credential.favorite);
        await _databaseService.toggleFavorite(id, updatedCredential.favorite);
        await updateCredential(updatedCredential);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<void> deleteCredential(String id, String categoryId) async {
    try {
      await _databaseService.deleteCredential(id);
      
      if (_credentialsByCategory.containsKey(categoryId)) {
        _credentialsByCategory[categoryId]!.removeWhere((c) => c.id == id);
      }
      
      _favoriteCredentials.removeWhere((c) => c.id == id);
      _recentlyUsedCredentials.removeWhere((c) => c.id == id);
      
      notifyListeners();
    } catch (e) {
      print('Error deleting credential: $e');
      rethrow;
    }
  }

  Future<void> searchCredentials(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _searchResults = await _databaseService.searchCredentials(query);
    } catch (e) {
      print('Error searching credentials: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void _updateRecentlyUsed(Credential credential) {
    _recentlyUsedCredentials.removeWhere((c) => c.id == credential.id);
    _recentlyUsedCredentials.insert(0, credential);
    
    if (_recentlyUsedCredentials.length > 10) {
      _recentlyUsedCredentials = _recentlyUsedCredentials.sublist(0, 10);
    }
    
    _databaseService.updateRecentlyUsed(credential.id);
  }

  Future<void> markAsRecentlyUsed(String id, String categoryId) async {
    try {
      Credential? credential;
      
      if (_credentialsByCategory.containsKey(categoryId)) {
        credential = _credentialsByCategory[categoryId]?.firstWhere(
          (c) => c.id == id,
        );
      }
      
      if (credential == null) {
        credential = await _databaseService.getCredentialById(id);
      }
      
      if (credential != null) {
        _updateRecentlyUsed(credential);
        notifyListeners();
      }
    } catch (e) {
      print('Error marking credential as recently used: $e');
    }
  }
}
