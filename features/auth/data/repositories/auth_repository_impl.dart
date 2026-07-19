import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/hash_util.dart';
import '../../../barcode/data/datasources/app_database.dart' as db;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_mapper.dart';

/// پیاده‌سازی AuthRepository با Drift و SecureStorage
class AuthRepositoryImpl implements AuthRepository {
  final db.AppDatabase _database;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({
    required db.AppDatabase database,
    required FlutterSecureStorage secureStorage,
  })  : _database = database,
        _secureStorage = secureStorage;

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    try {
      final userRow = await _database.getUserByUsername(username);

      if (userRow == null) {
        return const Left(AuthFailure(message: 'نام کاربری یا رمز عبور اشتباه است'));
      }

      if (!userRow.isActive) {
        return const Left(AuthFailure(message: 'حساب کاربری غیرفعال است'));
      }

      // Verify password
      final isValid = HashUtil.verifyPassword(
        password,
        userRow.salt,
        userRow.passwordHash,
      );

      if (!isValid) {
        return const Left(AuthFailure(message: 'نام کاربری یا رمز عبور اشتباه است'));
      }

      // Verify role
      if (UserRole.fromString(userRow.role) != role) {
        return Left(AuthFailure(
            message: 'این حساب کاربری نقش ${UserRole.fromString(userRow.role).label} دارد'));
      }

      final user = UserMapper.toEntity(userRow);
      await saveSession(user);

      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: 'خطا در ورود: $e'));
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: 'session_user_id');
    await _secureStorage.delete(key: 'session_username');
    await _secureStorage.delete(key: 'session_role');
    await _secureStorage.delete(key: 'session_full_name');
  }

  @override
  Future<User?> getCurrentUser() async {
    final userIdStr = await _secureStorage.read(key: 'session_user_id');
    if (userIdStr == null) return null;

    final id = int.tryParse(userIdStr);
    if (id == null) return null;

    final userRow = await _database.getUserById(id);
    return userRow != null ? UserMapper.toEntity(userRow) : null;
  }

  @override
  Future<void> saveSession(User user) async {
    await _secureStorage.write(key: 'session_user_id', value: user.id.toString());
    await _secureStorage.write(key: 'session_username', value: user.username);
    await _secureStorage.write(key: 'session_role', value: user.role.toDbValue());
    await _secureStorage.write(key: 'session_full_name', value: user.fullName);
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final userRow = await _database.getUserById(userId);
      if (userRow == null) {
        return const Left(AuthFailure(message: 'کاربر پیدا نشد'));
      }

      // Verify old password
      final isValid = HashUtil.verifyPassword(
        oldPassword,
        userRow.salt,
        userRow.passwordHash,
      );

      if (!isValid) {
        return const Left(AuthFailure(message: 'رمز عبور فعلی اشتباه است'));
      }

      // Generate new hash
      final newSalt = HashUtil.generateSalt();
      final newHash = HashUtil.hashPassword(newPassword, newSalt);

      // Update in database
      await (_database.update(_database.users)
            ..where((u) => u.id.equals(userId)))
          .write(db.UsersCompanion(
        passwordHash: Value(newHash),
        salt: Value(newSalt),
      ));

      return const Right(true);
    } catch (e) {
      return Left(AuthFailure(message: 'خطا در تغییر رمز: $e'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final rows = await _database.getAllUsers();
      return Right(UserMapper.toEntityList(rows));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت کاربران: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> createUser({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      // Check if username exists
      final existing = await _database.getUserByUsername(username);
      if (existing != null) {
        return const Left(AuthFailure(message: 'این نام کاربری قبلاً ثبت شده است'));
      }

      final companion = UserMapper.toCompanion(
        username: username,
        password: password,
        fullName: fullName,
        role: role,
      );

      final id = await _database.insertUser(companion);
      final newUserRow = await _database.getUserById(id);

      if (newUserRow == null) {
        return const Left(DatabaseFailure(message: 'خطا در ایجاد کاربر'));
      }

      return Right(UserMapper.toEntity(newUserRow));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در ایجاد کاربر: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deactivateUser(int userId) async {
    try {
      await (_database.update(_database.users)
            ..where((u) => u.id.equals(userId)))
          .write(db.UsersCompanion(isActive: const Value(false)));
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در غیرفعال‌سازی کاربر: $e'));
    }
  }
}
