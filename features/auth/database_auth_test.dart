import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:barcode_warehouse/features/barcode/data/datasources/app_database.dart' as db;

void main() {
  late db.AppDatabase database;

  setUp(() async {
    database = db.AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Admin Seed Tests', () {
    /// همان هش SHA-256 که در HashUtil و app_database استفاده می‌شود
    String sha256Hash(String password, String salt) {
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    test('admin user should be created on database init', () async {
      final admin = await database.getUserByUsername('admin');

      expect(admin, isNotNull);
      expect(admin!.username, 'admin');
      expect(admin.role, 'admin');
      expect(admin.isActive, true);
    });

    test('admin password hash should be SHA-256 of admin123+salt', () async {
      final expectedHash = sha256Hash('admin123', 'barcode_warehouse_default_salt_2024');

      final admin = await database.getUserByUsername('admin');
      expect(admin, isNotNull);
      expect(admin!.passwordHash, expectedHash);
      expect(admin.salt, 'barcode_warehouse_default_salt_2024');
    });

    test('verify admin/admin123 login should succeed', () async {
      final admin = await database.getUserByUsername('admin');
      expect(admin, isNotNull);

      final computedHash = sha256Hash('admin123', admin!.salt);
      final isPasswordValid = (computedHash == admin.passwordHash);

      expect(isPasswordValid, true,
          reason: 'ورود با admin/admin123 باید موفق باشد');
    });

    test('verify wrong password should fail', () async {
      final admin = await database.getUserByUsername('admin');
      expect(admin, isNotNull);

      final computedHash = sha256Hash('wrongpassword', admin!.salt);
      final isPasswordValid = (computedHash == admin.passwordHash);

      expect(isPasswordValid, false);
    });

    test('admin can change password and login with new one', () async {
      final admin = await database.getUserByUsername('admin');
      expect(admin, isNotNull);

      // تغییر رمز
      const newPassword = 'newpass456';
      final newSalt = 'new_salt_123';
      final newHash = sha256Hash(newPassword, newSalt);

      await (database.update(database.users)
            ..where((u) => u.id.equals(admin!.id)))
          .write(db.UsersCompanion(
        passwordHash: Value(newHash),
        salt: Value(newSalt),
      ));

      // بررسی رمز جدید
      final updatedAdmin = await database.getUserByUsername('admin');
      final computedHash = sha256Hash(newPassword, updatedAdmin!.salt);
      expect(computedHash, updatedAdmin.passwordHash);
    });
  });
}
