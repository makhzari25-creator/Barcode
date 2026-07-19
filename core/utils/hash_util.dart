import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

/// ابزار هش کردن رمز عبور با SHA-256 + Salt
class HashUtil {
  HashUtil._();

  /// تولید Salt تصادفی ۱۶ بایتی
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// هش کردن رمز عبور با Salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// تأیید رمز عبور
  static bool verifyPassword(String password, String salt, String hash) {
    final computedHash = hashPassword(password, salt);
    return computedHash == hash;
  }

  /// تولید شناسه یکتا
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(999999);
    return '$timestamp$random';
  }
}
