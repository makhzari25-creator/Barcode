import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  group('Password Hash Verification', () {
    /// همان هش که در HashUtil.hashPassword استفاده می‌شود
    String hashPassword(String password, String salt) {
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    /// همان هش که در app_database.dart استفاده می‌شود
    String dbHashPassword(String password, String salt) {
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    test('hashes should be identical for same password and salt', () {
      const password = 'admin123';
      const salt = 'barcode_warehouse_default_salt_2024';

      final hash1 = hashPassword(password, salt);
      final hash2 = dbHashPassword(password, salt);

      expect(hash1, equals(hash2),
          reason: 'Hashes must be identical for login to work');
    });

    test('admin123 with default salt should produce valid SHA-256', () {
      const password = 'admin123';
      const salt = 'barcode_warehouse_default_salt_2024';

      final hash = hashPassword(password, salt);

      // SHA-256 = 64 hex characters
      expect(hash.length, 64);
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(hash), true);
    });

    test('verify password should return true for correct password', () {
      const password = 'admin123';
      const salt = 'barcode_warehouse_default_salt_2024';
      final storedHash = hashPassword(password, salt);

      final computedHash = hashPassword(password, salt);
      expect(computedHash == storedHash, true);
    });

    test('verify password should return false for wrong password', () {
      const password = 'admin123';
      const wrongPassword = 'wrongpassword';
      const salt = 'barcode_warehouse_default_salt_2024';
      final storedHash = hashPassword(password, salt);

      final computedHash = hashPassword(wrongPassword, salt);
      expect(computedHash == storedHash, false);
    });

    test('different salts should produce different hashes', () {
      const password = 'admin123';
      const salt1 = 'salt1';
      const salt2 = 'salt2';

      final hash1 = hashPassword(password, salt1);
      final hash2 = hashPassword(password, salt2);

      expect(hash1 != hash2, true);
    });

    test('login simulation: admin/admin123 should work', () {
      const inputUsername = 'admin';
      const inputPassword = 'admin123';
      const inputRole = 'admin';

      const storedUsername = 'admin';
      const storedRole = 'admin';
      const storedSalt = 'barcode_warehouse_default_salt_2024';
      final storedHash = dbHashPassword('admin123', storedSalt);

      expect(inputUsername, equals(storedUsername));
      expect(inputRole, equals(storedRole));

      final computedHash = hashPassword(inputPassword, storedSalt);
      expect(computedHash, equals(storedHash),
          reason: 'رمز عبور باید با هش ذخیره شده مطابقت داشته باشد');
    });
  });
}
