import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/barcode/data/datasources/app_database.dart';
import 'features/barcode/data/repositories/barcode_repository_impl.dart';
import 'features/barcode/domain/repositories/barcode_repository.dart';
import 'features/barcode/domain/usecases/barcode_usecases.dart';
import 'features/import_export/data/repositories/import_export_repository_impl.dart';
import 'features/import_export/domain/repositories/import_export_repository.dart';
import 'features/import_export/domain/usecases/import_export_usecases.dart';
import 'features/picking/data/repositories/picking_repository_impl.dart';
import 'features/picking/domain/repositories/picking_repository.dart';
import 'features/picking/domain/usecases/picking_usecases.dart';
import 'features/scanner/data/repositories/scan_repository_impl.dart';
import 'features/scanner/domain/repositories/scan_repository.dart';
import 'features/scanner/domain/usecases/scan_usecases.dart';

// ============ Databases & Storage ============

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

// ============ Repositories ============

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(database: database, secureStorage: secureStorage);
});

final barcodeRepositoryProvider = Provider<BarcodeRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return BarcodeRepositoryImpl(database);
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ScanRepositoryImpl(database);
});

final importExportRepositoryProvider = Provider<ImportExportRepository>((ref) {
  return ImportExportRepositoryImpl();
});

// ============ Auth Use Cases ============

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
});

final getAllUsersUseCaseProvider = Provider<GetAllUsersUseCase>((ref) {
  return GetAllUsersUseCase(ref.watch(authRepositoryProvider));
});

final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  return CreateUserUseCase(ref.watch(authRepositoryProvider));
});

// ============ Barcode Use Cases ============

final isBarcodeValidUseCaseProvider = Provider<IsBarcodeValidUseCase>((ref) {
  return IsBarcodeValidUseCase(ref.watch(barcodeRepositoryProvider));
});

final getBarcodeUseCaseProvider = Provider<GetBarcodeUseCase>((ref) {
  return GetBarcodeUseCase(ref.watch(barcodeRepositoryProvider));
});

final getBarcodeCountUseCaseProvider = Provider<GetBarcodeCountUseCase>((ref) {
  return GetBarcodeCountUseCase(ref.watch(barcodeRepositoryProvider));
});

final getAllBarcodesUseCaseProvider = Provider<GetAllBarcodesUseCase>((ref) {
  return GetAllBarcodesUseCase(ref.watch(barcodeRepositoryProvider));
});

final addBarcodeUseCaseProvider = Provider<AddBarcodeUseCase>((ref) {
  return AddBarcodeUseCase(ref.watch(barcodeRepositoryProvider));
});

final replaceAllBarcodesUseCaseProvider = Provider<ReplaceAllBarcodesUseCase>((ref) {
  return ReplaceAllBarcodesUseCase(ref.watch(barcodeRepositoryProvider));
});

final addBarcodesUseCaseProvider = Provider<AddBarcodesUseCase>((ref) {
  return AddBarcodesUseCase(ref.watch(barcodeRepositoryProvider));
});

final deleteAllBarcodesUseCaseProvider = Provider<DeleteAllBarcodesUseCase>((ref) {
  return DeleteAllBarcodesUseCase(ref.watch(barcodeRepositoryProvider));
});

final reloadBloomFilterUseCaseProvider = Provider<ReloadBloomFilterUseCase>((ref) {
  return ReloadBloomFilterUseCase(ref.watch(barcodeRepositoryProvider));
});

// ============ Scan Use Cases ============

final validateBarcodeUseCaseProvider = Provider<ValidateBarcodeUseCase>((ref) {
  return ValidateBarcodeUseCase(
    ref.watch(barcodeRepositoryProvider),
    ref.watch(scanRepositoryProvider),
  );
});

final saveScanUseCaseProvider = Provider<SaveScanUseCase>((ref) {
  return SaveScanUseCase(ref.watch(scanRepositoryProvider));
});

final getScansUseCaseProvider = Provider<GetScansUseCase>((ref) {
  return GetScansUseCase(ref.watch(scanRepositoryProvider));
});

final getScanStatsUseCaseProvider = Provider<GetScanStatsUseCase>((ref) {
  return GetScanStatsUseCase(ref.watch(scanRepositoryProvider));
});

final clearOldScansUseCaseProvider = Provider<ClearOldScansUseCase>((ref) {
  return ClearOldScansUseCase(ref.watch(scanRepositoryProvider));
});

final clearAllScansUseCaseProvider = Provider<ClearAllScansUseCase>((ref) {
  return ClearAllScansUseCase(ref.watch(scanRepositoryProvider));
});

// ============ Import/Export Use Cases ============

final importBarcodesUseCaseProvider = Provider<ImportBarcodesUseCase>((ref) {
  return ImportBarcodesUseCase(
    ref.watch(importExportRepositoryProvider),
    ref.watch(barcodeRepositoryProvider),
  );
});

final exportBarcodesUseCaseProvider = Provider<ExportBarcodesUseCase>((ref) {
  return ExportBarcodesUseCase(
    ref.watch(importExportRepositoryProvider),
    ref.watch(barcodeRepositoryProvider),
  );
});

final exportScansUseCaseProvider = Provider<ExportScansUseCase>((ref) {
  return ExportScansUseCase(
    ref.watch(importExportRepositoryProvider),
    ref.watch(scanRepositoryProvider),
  );
});

// ============ Picking Repository ============

final pickingRepositoryProvider = Provider<PickingRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return PickingRepositoryImpl(database);
});

// ============ Picking Use Cases ============

final createPickingSessionUseCaseProvider =
    Provider<CreatePickingSessionUseCase>((ref) {
  return CreatePickingSessionUseCase(ref.watch(pickingRepositoryProvider));
});

final getActiveSessionUseCaseProvider =
    Provider<GetActiveSessionUseCase>((ref) {
  return GetActiveSessionUseCase(ref.watch(pickingRepositoryProvider));
});

final getUserSessionsUseCaseProvider =
    Provider<GetUserSessionsUseCase>((ref) {
  return GetUserSessionsUseCase(ref.watch(pickingRepositoryProvider));
});

final getAllSessionsUseCaseProvider =
    Provider<GetAllSessionsUseCase>((ref) {
  return GetAllSessionsUseCase(ref.watch(pickingRepositoryProvider));
});

final getSessionItemsUseCaseProvider =
    Provider<GetSessionItemsUseCase>((ref) {
  return GetSessionItemsUseCase(ref.watch(pickingRepositoryProvider));
});

final getNextPendingItemUseCaseProvider =
    Provider<GetNextPendingItemUseCase>((ref) {
  return GetNextPendingItemUseCase(ref.watch(pickingRepositoryProvider));
});

final validatePickingBarcodeUseCaseProvider =
    Provider<ValidatePickingBarcodeUseCase>((ref) {
  return ValidatePickingBarcodeUseCase(ref.watch(pickingRepositoryProvider));
});

final pickItemUseCaseProvider = Provider<PickItemUseCase>((ref) {
  return PickItemUseCase(ref.watch(pickingRepositoryProvider));
});

final skipItemUseCaseProvider = Provider<SkipItemUseCase>((ref) {
  return SkipItemUseCase(ref.watch(pickingRepositoryProvider));
});

final markWrongBarcodeUseCaseProvider =
    Provider<MarkWrongBarcodeUseCase>((ref) {
  return MarkWrongBarcodeUseCase(ref.watch(pickingRepositoryProvider));
});

final completeSessionUseCaseProvider =
    Provider<CompleteSessionUseCase>((ref) {
  return CompleteSessionUseCase(ref.watch(pickingRepositoryProvider));
});

final cancelSessionUseCaseProvider =
    Provider<CancelSessionUseCase>((ref) {
  return CancelSessionUseCase(ref.watch(pickingRepositoryProvider));
});

final deleteSessionUseCaseProvider =
    Provider<DeleteSessionUseCase>((ref) {
  return DeleteSessionUseCase(ref.watch(pickingRepositoryProvider));
});

final getSessionStatsUseCaseProvider =
    Provider<GetSessionStatsUseCase>((ref) {
  return GetSessionStatsUseCase(ref.watch(pickingRepositoryProvider));
});
