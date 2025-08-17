class ApplicationConstants {

  // Application Name
  static const String appName = 'Yuki\u0027s Password Manager';
  static const String applicationVersion = '1.0.0';

  // Application Routes
  static const String homeRoute = '/home';
  static const String pinSetupRoute = '/pin-setup';
  static const String pinLoginRoute = '/pin-login';
  static const String addCategoryRoute = '/add-category';
  static const String editCategoryRoute = '/edit-category';
  static const String addCredentialRoute = '/add-credential';
  static const String editCredentialRoute = '/edit-creditial';
  static const String viewCredentialRoute = '/view-credential';
  static const String searchRoute = '/search';
  static const String favoriteRoute = '/favorite';
  static const String settingsRoute = '/settings';
  static const String categoryCredentialRoute = '/category-credential';

  // Messages
  static const String errorLoadingData = 'Love, your data is unable to load';
  static const String errorSavingData = 'Love, your data is unable to save';
  
  static const String successCategoryAdded = 'Love, your category has been added successfully';
  static const String successCategoryEdited = 'Love, your category has been edited successfully';
  static const String successCategoryDeleted = 'Love, your category has been deleted successfully';

  static const String successCredentialAdded = 'Love, your credential has been added successfully';
  static const String successCredentialDeleted = 'Love, your credential has been deleted successfully';
  static const String successCredentialEdited = 'Love, your credential has been updated successfully';

  static const String successPasswordCopied = 'Love, your password has been copied to clipboard';
  static const String successFavoriteAdded = 'Love, your password has been added to the favorites successfully';
  static const String successRemoveFavoriteAdded = 'Love, your password has been removed in the favorites successfully';

  // Validation 
  static const String requiredField = 'Love, this field is required';
  static const String invalidEmail = 'Love, please enter a valid email address';
  static const String confirmDeleteCredential = 'Love, are you sure you want to delete this credential?';
  static const String confirmDeleteCategory = 'Love, are you sure you want to delete this category and all the credentials under it?';
}