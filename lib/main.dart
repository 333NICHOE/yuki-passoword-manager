import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/pin_service.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_category_screen.dart';
import 'screens/edit_category_screen.dart';
import 'screens/add_credential_screen.dart';
import 'screens/edit_credential_screen.dart';
import 'screens/view_credential_screen.dart';
import 'screens/category_credentials_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/credential_provider.dart';
import 'providers/category_provider.dart';

import 'utils/theme.dart';
import 'utils/constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CredentialProvider()),
      ],
      child: MaterialApp(
        title: ApplicationConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/pin-setup': (context) => const PinSetupScreen(),
          '/pin-login': (context) => const PinLoginScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case ApplicationConstants.categoryCredentialRoute:
              return MaterialPageRoute(
                builder: (context) => const CategoryCredentialsScreen(),
                settings: settings,
              );
            case ApplicationConstants.addCategoryRoute:
              return MaterialPageRoute(
                builder: (context) => const AddCategoryScreen(),
              );
            case ApplicationConstants.editCategoryRoute:
              return MaterialPageRoute(
                builder: (context) => const EditCategoryScreen(),
                settings: settings,
              );
            case ApplicationConstants.addCredentialRoute:
              return MaterialPageRoute(
                builder: (context) => const AddCredentialScreen(),
              );
            case ApplicationConstants.editCredentialRoute:
              return MaterialPageRoute(
                builder: (context) => const EditCredentialScreen(),
                settings: settings,
              );
            case ApplicationConstants.viewCredentialRoute:
              return MaterialPageRoute(
                builder: (context) => const ViewCredentialScreen(),
                settings: settings,
              );
            case ApplicationConstants.searchRoute:
              return MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              );
            case ApplicationConstants.favoriteRoute:
              return MaterialPageRoute(
                builder: (context) => const FavoritesScreen(),
              );
            case ApplicationConstants.settingsRoute:
              return MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final PinService _pinService = PinService();
  bool _isLoading = true;
  bool _isPinSetup = false;

  @override
  void initState() {
    super.initState();
    _checkPinSetup();
  }

  Future<void> _checkPinSetup() async {
    final isPinSetup = await _pinService.isPinSetup();
    setState(() {
      _isPinSetup = isPinSetup;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isPinSetup) {
      return const PinSetupScreen();
    }

    return const PinLoginScreen();
  }
}
