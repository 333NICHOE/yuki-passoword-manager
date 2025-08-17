import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credential_provider.dart';
import '../providers/category_provider.dart';
import '../utils/constant.dart';
import '../utils/theme.dart';
import '../models/credential.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';
import '../widgets/recently_used_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userName = "Yuki";
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      Provider.of<CredentialProvider>(context, listen: false).loadRecentlyUsedCredentials();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSearchBar(context),
                const SizedBox(height: 24),
                _buildCategoriesSection(),
                const SizedBox(height: 24),
                _buildRecentlyUsedSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddOptions(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, ApplicationConstants.favoriteRoute);
              break;
            case 2:
              Navigator.pushNamed(context, ApplicationConstants.searchRoute);
              break;
            case 3:
              Navigator.pushNamed(context, ApplicationConstants.settingsRoute);
              break;
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: Text(
                userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, size: 28),
          onPressed: () {
            // Show notifications
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ApplicationConstants.searchRoute);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              'Search Password',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
        Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            if (categoryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryCard(
                  title: 'Social',
                  color: AppTheme.blueCategory,
                  iconColor: AppTheme.iconBlue,
                  icon: Icons.people,
                  onTap: () {
                    _navigateToCategoryCredentials('Social');
                  },
                ),
                CategoryCard(
                  title: 'Finance',
                  color: AppTheme.greenCategory,
                  iconColor: AppTheme.iconGreen,
                  icon: Icons.account_balance_wallet,
                  onTap: () {
                    _navigateToCategoryCredentials('Finance');
                  },
                ),
                CategoryCard(
                  title: 'Shopping',
                  color: AppTheme.pinkCategory,
                  iconColor: AppTheme.iconPink,
                  icon: Icons.shopping_bag,
                  onTap: () {
                    _navigateToCategoryCredentials('Shopping');
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentlyUsedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Used',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
        Consumer<CredentialProvider>(
          builder: (context, credentialProvider, child) {
            if (credentialProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final recentCredentials = credentialProvider.recentlyUsedCredentials;
            
            if (recentCredentials.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No recently used credentials',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentCredentials.length,
              itemBuilder: (context, index) {
                final credential = recentCredentials[index];
                return RecentlyUsedItem(
                  credential: credential,
                  onTap: () {
                    _viewCredential(credential);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _navigateToCategoryCredentials(String categoryName) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final category = categoryProvider.categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => Category(id: '', name: categoryName),
    );
    
    Navigator.pushNamed(
      context,
      ApplicationConstants.categoryCredentialRoute,
      arguments: category,
    );
  }

  void _viewCredential(Credential credential) {
    Navigator.pushNamed(
      context,
      ApplicationConstants.viewCredentialRoute,
      arguments: {
        'credential': credential,
        'categoryId': credential.categoryId,
      },
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder, color: AppTheme.primaryColor),
                title: const Text('Add Category'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, ApplicationConstants.addCategoryRoute);
                },
              ),
              ListTile(
                leading: const Icon(Icons.password, color: AppTheme.primaryColor),
                title: const Text('Add Credential'),
                onTap: () {
                  Navigator.pop(context);
                  if (Provider.of<CategoryProvider>(context, listen: false).categories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please create a category first')),
                    );
                    Navigator.pushNamed(context, ApplicationConstants.addCategoryRoute);
                  } else {
                    Navigator.pushNamed(context, ApplicationConstants.addCredentialRoute);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
