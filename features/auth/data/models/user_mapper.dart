import 'package:drift/drift.dart';

import '../../../../core/utils/hash_util.dart';
import '../../../barcode/data/datasources/app_database.dart' as db;
import '../../domain/entities/user.dart';

/// Mapper برای تبدیل ردیف کاربر به Entity
class UserMapper {
  UserMapper._();

  /// تبدیل UserRow (DB) به User (Entity)
  static User toEntity(db.UserRow row) {
    return User(
      id: row.id,
      username: row.username,
      fullName: row.fullName,
      role: UserRole.fromString(row.role),
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }

  /// تبدیل لیست ردیف‌ها به Entity
  static List<User> toEntityList(List<db.UserRow> rows) {
    return rows.map(toEntity).toList();
  }

  /// ایجاد UsersCompanion برای Insert
  static db.UsersCompanion toCompanion({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
    bool isActive = true,
  }) {
    final salt = HashUtil.generateSalt();
    final passwordHash = HashUtil.hashPassword(password, salt);

    return db.UsersCompanion.insert(
      username: username,
      passwordHash: passwordHash,
      salt: salt,
      fullName: fullName,
      role: role.toDbValue(),
      isActive: Value(isActive),
    );
  }

  /// ایجاد UsersCompanion برای Update
  static db.UsersCompanion toUpdateCompanion({
    required int id,
    String? username,
    String? fullName,
    UserRole? role,
    bool? isActive,
  }) {
    return db.UsersCompanion(
      id: Value(id),
      username: username != null ? Value(username) : const Value.absent(),
      fullName: fullName != null ? Value(fullName) : const Value.absent(),
      role: role != null ? Value(role.toDbValue()) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
    );
  }
}
