import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// جدول کاربران
@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 3, max: 50)();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  TextColumn get fullName => text().withLength(min: 2, max: 100)();
  TextColumn get role => text().withLength(min: 5, max: 10)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {username},
      ];
}

/// جدول دسته‌های Import
@DataClassName('ImportBatchRow')
class ImportBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get fileName => text()();
  IntColumn get totalRecords => integer().withDefault(const Constant(0))();
  BoolColumn get replaced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();
}

/// جدول بارکدهای مجاز
@DataClassName('BarcodeRow')
class Barcodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().withLength(min: 1, max: 100)();
  TextColumn get productName => text().nullable()();
  TextColumn get productCode => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get size => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get importedBatch => integer().nullable().references(ImportBatches, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {code},
      ];
}

/// جدول اسکن‌های ثبت‌شده
@DataClassName('ScanRow')
class Scans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get barcode => text()();
  TextColumn get status => text()(); // valid, invalid, duplicate
  DateTimeColumn get scannedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get dateOnly => text()(); // YYYY-MM-DD
  TextColumn get timeOnly => text()(); // HH:MM:SS
  TextColumn get deviceInfo => text().nullable()();
}

/// جدول نشست‌های برداشت
@DataClassName('PickingSessionRow')
class PickingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sourceFile => text()();
  IntColumn get totalItems => integer().withDefault(const Constant(0))();
  IntColumn get pickedCount => integer().withDefault(const Constant(0))();
  IntColumn get skippedCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// جدول آیتم‌های برداشت (هر ردیف از فایل اکسل)
@DataClassName('PickingItemRow')
class PickingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(PickingSessions, #id)();
  TextColumn get locationWarehouse => text()();
  TextColumn get locationHall => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get productCode => text().nullable()();
  TextColumn get productName => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get gender => text().nullable()();
  TextColumn get design => text().nullable()();
  TextColumn get size => text().nullable()();
  TextColumn get barcode => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get scannedBarcode => text().nullable()();
  DateTimeColumn get pickedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// دیتابیس اصلی اپلیکیشن
@DriftDatabase(tables: [Users, ImportBatches, Barcodes, Scans, PickingSessions, PickingItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// برای تست
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultAdmin();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // در نسخه ۱، هش رمز عبور مدیر اشتباه بود
            // در نسخه ۲، رمز مدیر را با هش صحیح SHA-256 به‌روزرسانی می‌کنیم
            await _fixAdminPasswordHash();
          }
          if (from < 3) {
            // در نسخه ۳، جداول سیستم برداشت اضافه می‌شوند
            await m.createTable(pickingSessions);
            await m.createTable(pickingItems);
            // ایندکس‌ها برای جستجوی سریع
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_picking_items_session_id ON picking_items(session_id)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_picking_items_barcode ON picking_items(barcode)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_picking_items_location ON picking_items(location_warehouse)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_picking_items_status ON picking_items(status)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_picking_sessions_user_id ON picking_sessions(user_id)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_picking_sessions_status ON picking_sessions(status)',
            );
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // Enable performance optimizations
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = NORMAL');
          await customStatement('PRAGMA cache_size = -64000'); // 64MB cache

          // اطمینان از وجود کاربر مدیر (در صورت عدم وجود)
          if (details.wasCreated || details.hadUpgrade) {
            await _ensureAdminExists();
          }
        },
      );

  /// به‌روزرسانی هش رمز عبور مدیر به SHA-256 صحیح
  Future<void> _fixAdminPasswordHash() async {
    final salt = 'barcode_warehouse_default_salt_2024';
    final correctHash = _hashPassword('admin123', salt);

    await (update(users)..where((u) => u.username.equals('admin'))).write(
      UsersCompanion(
        passwordHash: Value(correctHash),
        salt: Value(salt),
      ),
    );
  }

  /// اطمینان از وجود کاربر مدیر
  Future<void> _ensureAdminExists() async {
    final existing = await (select(users)
          ..where((u) => u.username.equals('admin')))
        .getSingleOrNull();

    if (existing == null) {
      await _seedDefaultAdmin();
    } else {
      // بررسی صحت هش - اگر قدیمی بود، به‌روزرسانی کن
      final salt = 'barcode_warehouse_default_salt_2024';
      final correctHash = _hashPassword('admin123', salt);
      if (existing.passwordHash != correctHash) {
        await (update(users)..where((u) => u.username.equals('admin'))).write(
          UsersCompanion(
            passwordHash: Value(correctHash),
            salt: Value(salt),
          ),
        );
      }
    }
  }

  /// ایجاد کاربر مدیر پیش‌فرض در اولین اجرا
  Future<void> _seedDefaultAdmin() async {
    final existing = await (select(users)
          ..where((u) => u.username.equals('admin')))
        .getSingleOrNull();

    if (existing == null) {
      // Hash the default password "admin123" with a static salt for first-time setup
      // The user will be required to change it on first login (Phase 4 feature)
      final salt = 'barcode_warehouse_default_salt_2024';
      final passwordHash = _hashPassword('admin123', salt);

      await into(users).insert(UsersCompanion.insert(
        username: 'admin',
        passwordHash: passwordHash,
        salt: salt,
        fullName: 'مدیر سیستم',
        role: 'admin',
      ));
    }
  }

  String _hashPassword(String password, String salt) {
    // SHA-256 hash with salt - مطابق با HashUtil.hashPassword
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ============ Users ============

  Future<UserRow?> getUserByUsername(String username) {
    return (select(users)
          ..where((u) => u.username.equals(username))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<UserRow?> getUserById(int id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<List<UserRow>> getAllUsers() {
    return (select(users)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]))
        .get();
  }

  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<bool> updateUser(UsersCompanion user) async {
    final count = await (update(users)..where((u) => u.id.equals(user.id.value))).write(user);
    return count > 0;
  }

  Future<int> deleteUser(int id) {
    return (delete(users)..where((u) => u.id.equals(id))).go();
  }

  // ============ Barcodes ============

  Future<BarcodeRow?> getBarcodeByCode(String code) {
    return (select(barcodes)
          ..where((b) => b.code.equals(code))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<BarcodeRow>> getAllBarcodes({int limit = 100, int offset = 0}) {
    return (select(barcodes)
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<int> getBarcodeCount() async {
    final count = countAll();
    final query = selectOnly(barcodes)..addColumns([count]);
    final result = await query.map((row) => row.read(count)).getSingle();
    return result ?? 0;
  }

  Future<void> insertBarcode(BarcodesCompanion barcode) async {
    await into(barcodes).insert(barcode, mode: InsertMode.insertOrIgnore);
  }

  Future<void> insertBarcodesBatch(List<BarcodesCompanion> barcodeList) async {
    await batch((batch) {
      batch.insertAll(barcodes, barcodeList, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> deleteAllBarcodes() {
    return delete(barcodes).go();
  }

  /// دریافت همه بارکدها برای بارگذاری در Bloom Filter
  Future<List<String>> getAllBarcodeCodes() async {
    final query = selectOnly(barcodes, distinct: true)..addColumns([barcodes.code]);
    final result = await query.map((row) => row.read(barcodes.code)).get();
    return result.whereType<String>().toList();
  }

  // ============ Scans ============

  Future<int> insertScan(ScansCompanion scan) {
    return into(scans).insert(scan);
  }

  Future<ScanRow?> getLastScanForBarcode(String barcode) {
    return (select(scans)
          ..where((s) => s.barcode.equals(barcode))
          ..orderBy([(s) => OrderingTerm.desc(s.scannedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<bool> hasBarcodeBeenScannedToday(String barcode, String dateOnly) async {
    final count = countAll();
    final query = selectOnly(scans)
      ..addColumns([count])
      ..where(scans.barcode.equals(barcode) & scans.dateOnly.equals(dateOnly));
    final result = await query.map((row) => row.read(count)).getSingle();
    return (result ?? 0) > 0;
  }

  Future<List<ScanRow>> getScans({
    String? startDate,
    String? endDate,
    int? userId,
    int limit = 100,
    int offset = 0,
  }) {
    final query = select(scans);
    if (startDate != null) {
      query.where((s) => s.dateOnly.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((s) => s.dateOnly.isSmallerOrEqualValue(endDate));
    }
    if (userId != null) {
      query.where((s) => s.userId.equals(userId));
    }
    query
      ..orderBy([(s) => OrderingTerm.desc(s.scannedAt)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  /// آمار اسکن‌ها
  Future<ScanStatsData> getScanStats({
    String? startDate,
    String? endDate,
    int? userId,
  }) async {
    // Build WHERE clause manually
    final whereClauses = <String>[];
    final args = <Object>[];

    if (startDate != null) {
      whereClauses.add('date_only >= ?');
      args.add(startDate);
    }
    if (endDate != null) {
      whereClauses.add('date_only <= ?');
      args.add(endDate);
    }
    if (userId != null) {
      whereClauses.add('user_id = ?');
      args.add(userId);
    }

    final whereSql =
        whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}';

    final sql = '''
      SELECT
        COUNT(*) as total,
        SUM(CASE WHEN status = 'valid' THEN 1 ELSE 0 END) as valid,
        SUM(CASE WHEN status = 'invalid' THEN 1 ELSE 0 END) as invalid,
        SUM(CASE WHEN status = 'duplicate' THEN 1 ELSE 0 END) as duplicate
      FROM scans
      $whereSql
    ''';

    final result = await customSelect(sql, variables: args.map((a) => Variable(a)).toList())
        .getSingle();

    return ScanStatsData(
      total: result.read<int>('total'),
      valid: result.read<int>('valid'),
      invalid: result.read<int>('invalid'),
      duplicate: result.read<int>('duplicate'),
    );
  }

  Future<int> deleteScansBeforeDate(String dateOnly) {
    return (delete(scans)..where((s) => s.dateOnly.isSmallerThanValue(dateOnly))).go();
  }

  Future<int> deleteAllScans() {
    return delete(scans).go();
  }

  // ============ Import Batches ============

  Future<int> insertImportBatch(ImportBatchesCompanion batch) {
    return into(importBatches).insert(batch);
  }

  Future<List<ImportBatchRow>> getAllImportBatches() {
    return (select(importBatches)
          ..orderBy([(b) => OrderingTerm.desc(b.importedAt)]))
        .get();
  }

  // ============ Picking Sessions ============

  /// ایجاد نشست برداشت جدید
  Future<int> insertPickingSession(PickingSessionsCompanion session) {
    return into(pickingSessions).insert(session);
  }

  /// به‌روزرسانی نشست برداشت
  Future<bool> updatePickingSession(PickingSessionsCompanion session) async {
    final count = await (update(pickingSessions)
          ..where((s) => s.id.equals(session.id.value)))
        .write(session);
    return count > 0;
  }

  /// دریافت نشست با شناسه
  Future<PickingSessionRow?> getPickingSessionById(int id) {
    return (select(pickingSessions)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// دریافت نشست فعال کاربر
  Future<PickingSessionRow?> getActivePickingSession(int userId) {
    return (select(pickingSessions)
          ..where((s) => s.userId.equals(userId) & s.status.equals('active'))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// دریافت همه نشست‌های کاربر
  Future<List<PickingSessionRow>> getPickingSessionsByUser(
    int userId, {
    int limit = 50,
    int offset = 0,
  }) {
    return (select(pickingSessions)
          ..where((s) => s.userId.equals(userId))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// دریافت همه نشست‌ها (برای مدیر)
  Future<List<PickingSessionRow>> getAllPickingSessions({
    int limit = 100,
    int offset = 0,
  }) {
    return (select(pickingSessions)
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// حذف نشست
  Future<int> deletePickingSession(int id) {
    return (delete(pickingSessions)..where((s) => s.id.equals(id))).go();
  }

  // ============ Picking Items ============

  /// درج آیتم برداشت
  Future<int> insertPickingItem(PickingItemsCompanion item) {
    return into(pickingItems).insert(item);
  }

  /// درج batch آیتم‌های برداشت
  Future<void> insertPickingItemsBatch(List<PickingItemsCompanion> items) async {
    await batch((b) {
      b.insertAll(pickingItems, items);
    });
  }

  /// به‌روزرسانی آیتم برداشت
  Future<bool> updatePickingItem(PickingItemsCompanion item) async {
    final count = await (update(pickingItems)
          ..where((i) => i.id.equals(item.id.value)))
        .write(item);
    return count > 0;
  }

  /// دریافت آیتم‌های نشست
  Future<List<PickingItemRow>> getPickingItemsBySession(int sessionId) {
    return (select(pickingItems)
          ..where((i) => i.sessionId.equals(sessionId))
          ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
        .get();
  }

  /// دریافت آیتم با شناسه
  Future<PickingItemRow?> getPickingItemById(int id) {
    return (select(pickingItems)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
  }

  /// جستجوی آیتم با بارکد در نشست
  Future<PickingItemRow?> getPickingItemByBarcode(
    int sessionId,
    String barcode,
  ) {
    return (select(pickingItems)
          ..where(
              (i) => i.sessionId.equals(sessionId) & i.barcode.equals(barcode))
          ..limit(1))
        .getSingleOrNull();
  }

  /// شمارش آیتم‌های نشست با وضعیت مشخص
  Future<int> countPickingItemsByStatus(int sessionId, String status) async {
    final count = countAll();
    final query = selectOnly(pickingItems)
      ..addColumns([count])
      ..where(pickingItems.sessionId.equals(sessionId) &
          pickingItems.status.equals(status));
    final result = await query.map((row) => row.read(count)).getSingle();
    return result ?? 0;
  }

  /// حذف همه آیتم‌های نشست
  Future<int> deletePickingItemsBySession(int sessionId) {
    return (delete(pickingItems)
          ..where((i) => i.sessionId.equals(sessionId)))
        .go();
  }

  /// دریافت اولین آیتم pending نشست (با کمترین sortOrder)
  Future<PickingItemRow?> getFirstPendingPickingItem(int sessionId) {
    return (select(pickingItems)
          ..where((i) =>
              i.sessionId.equals(sessionId) & i.status.equals('pending'))
          ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// دریافت تعداد کل آیتم‌های pending
  Future<int> getPendingPickingItemsCount(int sessionId) async {
    final count = countAll();
    final query = selectOnly(pickingItems)
      ..addColumns([count])
      ..where(pickingItems.sessionId.equals(sessionId) &
          pickingItems.status.equals('pending'));
    final result = await query.map((row) => row.read(count)).getSingle();
    return result ?? 0;
  }
}

/// آمار اسکن
class ScanStatsData {
  final int total;
  final int valid;
  final int invalid;
  final int duplicate;

  const ScanStatsData({
    required this.total,
    required this.valid,
    required this.invalid,
    required this.duplicate,
  });

  factory ScanStatsData.empty() =>
      const ScanStatsData(total: 0, valid: 0, invalid: 0, duplicate: 0);
}

/// باز کردن اتصال به دیتابیس
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'barcode_warehouse.db'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON');
        db.execute('PRAGMA journal_mode = WAL');
      },
    );
  });
}
