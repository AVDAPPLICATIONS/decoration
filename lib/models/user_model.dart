class UserModel {
  final int? id;
  final String username;
  final String role;
  final String? email;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.role,
    this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    int? id,
    String? username,
    String? role,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// If you're registering a new user with password:
Map<String, dynamic> registrationPayload({
  required String username,
  required String email,
  required String password,
  required String role,
}) {
  return {
    'username': username,
    'email': email,
    'password': password,
    'role': role,
  };
}
