/// موجودیت نقش کاربر
enum UserRole {
  admin('مدیر'),
  operator('اپراتور');

  final String label;
  const UserRole(this.label);

  bool get isAdmin => this == UserRole.admin;
  bool get isOperator => this == UserRole.operator;

  static UserRole fromString(String? value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'operator' => UserRole.operator,
      _ => UserRole.operator,
    };
  }

  String toDbValue() => name;
}

/// موجودیت کاربر (Entity خالص - بدون وابستگی به فریم‌ورک)
class User {
  final int? id;
  final String username;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  const User({
    this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  User copyWith({
    int? id,
    String? username,
    String? fullName,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, username: $username, role: $role)';
}
