/// استثناهای سفارشی اپلیکیشن
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic original;

  const AppException({required this.message, this.code, this.original});

  @override
  String toString() => 'AppException($code): $message';
}

class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code = 'DATABASE_ERROR', super.original});
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code = 'AUTH_ERROR', super.original});
}

class ImportException extends AppException {
  const ImportException({required super.message, super.code = 'IMPORT_ERROR', super.original});
}

class ExportException extends AppException {
  const ExportException({required super.message, super.code = 'EXPORT_ERROR', super.original});
}

class CameraException extends AppException {
  const CameraException({required super.message, super.code = 'CAMERA_ERROR', super.original});
}

class FileNotFoundException extends AppException {
  const FileNotFoundException({required super.message, super.code = 'FILE_NOT_FOUND', super.original});
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException({required super.message, super.code = 'PERMISSION_DENIED', super.original});
}
