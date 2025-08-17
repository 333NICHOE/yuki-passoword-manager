import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category.dart';
import '../models/credential.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  // Current database version - increased to handle schema updates
  static const int _databaseVersion = 1;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'password_manager.db');
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Create credentials table with favorite and last_used fields
    await db.execute('''
      CREATE TABLE credentials(
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        website TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        favorite INTEGER DEFAULT 0,
        last_used INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  // Sample data insertion with favorites and timestamps
  Future<void> _insertSampleData(Database db) async {
    // Current timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Sample categories
    final categories = [
      {'id': '1', 'name': 'Social'},
      {'id': '2', 'name': 'Finance'},
      {'id': '3', 'name': 'Shopping'},
    ];

    // Sample credentials with favorite field and last_used timestamps
    final credentials = [
      {
        'id': '101',
        'category_id': '1',
        'website': 'Google Account',
        'username': 'rahulornob@gmail.com',
        'password': 'GoogleP@ss123',
        'favorite': 1,
        'last_used': now,
      },
      {
        'id': '102',
        'category_id': '1',
        'website': 'Netflix Personal',
        'username': 'rahulornob@gmail.com',
        'password': 'NetflixSecure!',
        'favorite': 0,
        'last_used': now - 60000,
      },
      {
        'id': '103',
        'category_id': '1',
        'website': 'Twitter',
        'username': 'rahulornob',
        'password': 'TwitterP@ss123',
        'favorite': 0,
        'last_used': now - 120000,
      },
      {
        'id': '104',
        'category_id': '1',
        'website': 'Dribbble Pro',
        'username': 'rahulornob@gmail.com',
        'password': 'DribbbleP@ss123',
        'favorite': 0,
        'last_used': now - 180000,
      },
    ];

    // Insert categories
    for (var category in categories) {
      await db.insert('categories', category);
    }

    // Insert credentials
    for (var credential in credentials) {
      await db.insert('credentials', credential);
    }
  }

  // CRUD operations for categories (unchanged)
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Updated credential operations with favorite and recently used support
  Future<List<Credential>> getCredentialsByCategoryId(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credentials',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Credential.fromMap(maps[i]));
  }

  // Get favorite credentials
  Future<List<Credential>> getFavoriteCredentials() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credentials',
      where: 'favorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Credential.fromMap(maps[i]));
  }

  // Get recently used credentials
  Future<List<Credential>> getRecentlyUsedCredentials() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credentials',
      orderBy: 'last_used DESC',
      limit: 10,
    );
    return List.generate(maps.length, (i) => Credential.fromMap(maps[i]));
  }

  Future<Credential> getCredentialById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credentials',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Credential.fromMap(maps.first);
  }

  Future<void> insertCredential(Credential credential) async {
    final db = await database;
    
    // Set last_used to current timestamp
    final Map<String, dynamic> credentialMap = credential.toMap();
    credentialMap['last_used'] = DateTime.now().millisecondsSinceEpoch;
    
    await db.insert(
      'credentials',
      credentialMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCredential(Credential credential) async {
    final db = await database;
    
    // Set last_used to current timestamp
    final Map<String, dynamic> credentialMap = credential.toMap();
    credentialMap['last_used'] = DateTime.now().millisecondsSinceEpoch;
    
    await db.update(
      'credentials',
      credentialMap,
      where: 'id = ?',
      whereArgs: [credential.id],
    );
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'credentials',
      {'favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update last_used timestamp
  Future<void> updateRecentlyUsed(String id) async {
    final db = await database;
    await db.update(
      'credentials',
      {'last_used': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCredential(String id) async {
    final db = await database;
    await db.delete(
      'credentials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Enhanced search functionality
  Future<List<Map<String, dynamic>>> searchCredentials(String query) async {
    final db = await database;
    
    // More comprehensive search query
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        c.id, 
        c.website, 
        c.username, 
        c.password, 
        c.category_id, 
        c.favorite,
        c.last_used,
        cat.name as category_name
      FROM credentials c
      JOIN categories cat ON c.category_id = cat.id
      WHERE 
        c.website LIKE ? OR 
        c.username LIKE ? OR
        cat.name LIKE ?
      ORDER BY 
        c.last_used DESC
    ''', ['%$query%', '%$query%', '%$query%']);
    
    return results;
  }
}
