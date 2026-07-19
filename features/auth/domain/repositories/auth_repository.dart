import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

/// قرارداد Repository احراز هویت
abstract class AuthRepository {
  /// ورود کاربر با نام کاربری و رمز عبور و نقش
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
    required UserRole role,
  });

  /// خروج کاربر
  Future<void> logout();

  /// دریافت کاربر فعلی
  Future<User?> getCurrentUser();

  /// ذخیره نشست کاربر
  Future<void> saveSession(User user);

  /// تغییر رمز عبور
  Future<Either<Failure, bool>> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  });

  /// دریافت همه کاربران (فقط مدیر)
  Future<Either<Failure, List<User>>> getAllUsers();

  /// ایجاد کاربر جدید (فقط مدیر)
  Future<Either<Failure, User>> createUser({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
  });

  /// غیرفعال‌سازی کاربر (فقط مدیر)
  Future<Either<Failure, bool>> deactivateUser(int userId);
}
