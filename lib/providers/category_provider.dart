import 'package:flutter/foundation.dart';
import '../models/category.dart' as model;
import '../services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<model.Category> _categories = [];
  bool _isLoading = false;

  List<model.Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _databaseService.getCategories();
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(model.Category category) async {
    try {
      await _databaseService.insertCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(model.Category category) async {
    try {
      await _databaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _databaseService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }
}
