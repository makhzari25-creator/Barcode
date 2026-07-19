import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Use Case: ورود کاربر
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
    required UserRole role,
  }) {
    return _repository.login(
      username: username,
      password: password,
      role: role,
    );
  }
}

/// Use Case: خروج کاربر
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

/// Use Case: دریافت کاربر فعلی
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User?> call() => _repository.getCurrentUser();
}

/// Use Case: تغییر رمز عبور
class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      userId: userId,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

/// Use Case: دریافت همه کاربران (فقط مدیر)
class GetAllUsersUseCase {
  final AuthRepository _repository;

  GetAllUsersUseCase(this._repository);

  Future<Either<Failure, List<User>>> call() => _repository.getAllUsers();
}

/// Use Case: ایجاد کاربر جدید (فقط مدیر)
class CreateUserUseCase {
  final AuthRepository _repository;

  CreateUserUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
  }) {
    return _repository.createUser(
      username: username,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
