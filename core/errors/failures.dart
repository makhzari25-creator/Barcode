/// کلاس‌های خطا و Failure برای مدیریت یکپاخچه خطاها
/// الگوی Either (Left/Right) برای بازگشت موفقیت/خطا

/// کلاس پایه Failure
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => message;
}

/// خطای اعتبارسنجی
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code = 'VALIDATION_ERROR'});
}

/// خطای احراز هویت
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code = 'AUTH_ERROR'});
}

/// خطای پایگاه داده
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code = 'DATABASE_ERROR'});
}

/// خطای فایل
class FileFailure extends Failure {
  const FileFailure({required super.message, super.code = 'FILE_ERROR'});
}

/// خطای Import
class ImportFailure extends Failure {
  const ImportFailure({required super.message, super.code = 'IMPORT_ERROR'});
}

/// خطای Export
class ExportFailure extends Failure {
  const ExportFailure({required super.message, super.code = 'EXPORT_ERROR'});
}

/// خطای دوربین
class CameraFailure extends Failure {
  const CameraFailure({required super.message, super.code = 'CAMERA_ERROR'});
}

/// خطای شبکه
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code = 'NETWORK_ERROR'});
}

/// خطای عمومی
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code = 'UNKNOWN_ERROR'});
}

/// کلاس Either برای بازگشت موفقیت/خطا
sealed class Either<L, R> {
  const Either();

  bool get isSuccess => this is Right<L, R>;
  bool get isFailure => this is Left<L, R>;

  /// تبدیل در صورت موفقیت
  Either<L, T> map<T>(T Function(R) f) {
    return switch (this) {
      Right(value: final v) => Right<L, T>(f(v)),
      Left(value: final l) => Left<L, T>(l),
    };
  }

  /// ترکیب با Either دیگر
  Either<L, R> flatMap(Either<L, R> Function(R) f) {
    return switch (this) {
      Right(value: final v) => f(v),
      Left() => this,
    };
  }

  /// گرفتن مقدار یا default
  R getOrElse(R Function() orElse) {
    return switch (this) {
      Right(value: final v) => v,
      Left() => orElse(),
    };
  }

  /// گرفتن مقدار در صورت موفقیت
  R? getOrNull() {
    return switch (this) {
      Right(value: final v) => v,
      Left() => null,
    };
  }

  /// گرفتن خطا در صورت شکست
  L? getErrorOrNull() {
    return switch (this) {
      Right() => null,
      Left(value: final l) => l,
    };
  }

  /// الگوی fold برای تطبیق هر دو حالت
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return switch (this) {
      Left(value: final l) => onLeft(l),
      Right(value: final r) => onRight(r),
    };
  }
}

/// حالت موفقیت
final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}

/// حالت خطا
final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}
