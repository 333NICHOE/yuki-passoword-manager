class AppConstants {
  // App info
  static const String appName = "Password Manager";
  static const String appVersion = "1.0.0";
  
  // Routes
  static const String homeRoute = '/';
  static const String addCategoryRoute = '/add-category';
  static const String editCategoryRoute = '/edit-category';
  static const String addCredentialRoute = '/add-credential';
  static const String editCredentialRoute = '/edit-credential';
  static const String viewCredentialRoute = '/view-credential';
  static const String searchRoute = '/search';
  static const String settingsRoute = '/settings';
  static const String favoritesRoute = '/favorites';
  static const String categoryCredentialsRoute = '/category-credentials';
  static const String categoriesRoute = '/categories';
  static const String credentialsRoute = '/credentials';
  
  // Messages
  static const String errorLoadingData = 'Error loading data';
  static const String errorSavingData = 'Error saving data';
  static const String successCategoryAdded = 'Category added successfully';
  static const String successCategoryUpdated = 'Category updated successfully';
  static const String successCategoryDeleted = 'Category deleted successfully';
  static const String successCredentialAdded = 'Credential added successfully';
  static const String successCredentialUpdated = 'Credential updated successfully';
  static const String successCredentialDeleted = 'Credential deleted successfully';
  static const String successPasswordCopied = 'Password copied to clipboard';
  static const String successFavoriteAdded = 'Added to favorites';
  static const String successFavoriteRemoved = 'Removed from favorites';
  
  // Validation messages
  static const String requiredField = 'This field is required';
  static const String confirmDeleteCategory = 'Are you sure you want to delete this category and all its credentials? This action cannot be undone.';
  static const String confirmDeleteCredential = 'Are you sure you want to delete this credential? This action cannot be undone.';
}
