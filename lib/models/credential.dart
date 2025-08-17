class Credential {
  final String id;
  final String categoryId;
  final String website;
  final String username;
  final String password;
  final bool favorite;
  final int lastUsed;

  Credential({
    required this.id,
    required this.categoryId,
    required this.website,
    required this.username,
    required this.password,
    this.favorite = false,
    this.lastUsed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'website': website,
      'username': username,
      'password': password,
      'favorite': favorite ? 1 : 0,
      'last_used': lastUsed,
    };
  }

  factory Credential.fromMap(Map<String, dynamic> map) {
    return Credential(
      id: map['id'],
      categoryId: map['category_id'],
      website: map['website'],
      username: map['username'],
      password: map['password'],
      favorite: map['favorite'] == 1,
      lastUsed: map['last_used'] ?? 0,
    );
  }

  Credential copyWith({
    String? id,
    String? categoryId,
    String? website,
    String? username,
    String? password,
    bool? favorite,
    int? lastUsed,
  }) {
    return Credential(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      website: website ?? this.website,
      username: username ?? this.username,
      password: password ?? this.password,
      favorite: favorite ?? this.favorite,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
