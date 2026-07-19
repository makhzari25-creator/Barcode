// lib/features/import_export/presentation/providers/import_provider.dart
//
// Provider برای مدیریت Import فایل و ایجاد نشست برداشت
//

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../picking/domain/entities/picking_item.dart';
import '../../../picking/presentation/providers/picking_provider.dart';
import '../../data/repositories/import_export_repository_impl.dart';
import '../../domain/entities/import_export_entities.dart';
import '../../domain/usecases/import_export_usecases.dart';

/// وضعیت صفحه Import
@immutable
class ImportState {
  final bool isLoading;
  final String? selectedFilePath;
  final String? selectedFileName;
  final int? fileSize;
  final int? estimatedRecords;
  final ImportMode mode;
  final double progress;
  final ImportResult? result;
  final String? errorMessage;

  /// آیتم‌های خوانده‌شده از فایل (برای ایجاد نشست برداشت)
  final List<PickingItem>? pickedItems;

  const ImportState({
    this.isLoading = false,
    this.selectedFilePath,
    this.selectedFileName,
    this.fileSize,
    this.estimatedRecords,
    this.mode = ImportMode.replace,
    this.progress = 0,
    this.result,
    this.errorMessage,
    this.pickedItems,
  });

  ImportState copyWith({
    bool? isLoading,
    String? selectedFilePath,
    String? selectedFileName,
    int? fileSize,
    int? estimatedRecords,
    ImportMode? mode,
    double? progress,
    ImportResult? result,
    String? errorMessage,
    List<PickingItem>? pickedItems,
  }) {
    return ImportState(
      isLoading: isLoading ?? this.isLoading,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      fileSize: fileSize ?? this.fileSize,
      estimatedRecords: estimatedRecords ?? this.estimatedRecords,
      mode: mode ?? this.mode,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      errorMessage: errorMessage,
      pickedItems: pickedItems ?? this.pickedItems,
    );
  }

  factory ImportState.initial() => const ImportState();
}

/// State Notifier برای Import
class ImportNotifier extends StateNotifier<ImportState> {
  final ImportBarcodesUseCase _importUseCase;
  final ImportExportRepositoryImpl _importExportRepo;
  final AuthState _authState;
  final PickingNotifier _pickingNotifier;

  ImportNotifier(
    this._importUseCase,
    this._importExportRepo,
    this._authState,
    this._pickingNotifier,
  ) : super(ImportState.initial());

  /// انتخاب فایل
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      state = state.copyWith(
        selectedFilePath: file.path,
        selectedFileName: file.name,
        fileSize: file.size,
        estimatedRecords: null,
        result: null,
        errorMessage: null,
        progress: 0,
        pickedItems: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطا در انتخاب فایل: $e');
    }
  }

  /// تغییر حالت Import
  void setMode(ImportMode mode) {
    state = state.copyWith(mode: mode, result: null);
  }

  /// شروع Import
  ///
  /// این متد:
  /// ۱. فایل را می‌خواند و آیتم‌های برداشت را استخراج می‌کند
  /// ۲. آیتم‌ها را بر اساس م.ف.ا مرتب می‌کند (به‌صورت خودکار در Repository)
  /// ۳. یک نشست برداشت جدید ایجاد می‌کند
  Future<void> startImport() async {
    if (state.selectedFilePath == null) {
      state = state.copyWith(errorMessage: 'ابتدا یک فایل انتخاب کنید');
      return;
    }

    if (!_authState.isAuthenticated || _authState.user == null) {
      state = state.copyWith(errorMessage: 'کاربر وارد نشده است');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      progress: 0,
      result: null,
      errorMessage: null,
      pickedItems: null,
    );

    try {
      // پیشرفت ۱۰٪
      state = state.copyWith(progress: 0.1);

      // خواندن آیتم‌های برداشت از فایل
      final items = await _importExportRepo.readPickingItemsFromFile(
        state.selectedFilePath!,
      );

      // پیشرفت ۵۰٪
      state = state.copyWith(progress: 0.5, pickedItems: items);

      if (items.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'هیچ آیتم معتبری در فایل پیدا نشد.',
        );
        return;
      }

      // پیشرفت ۷۰٪
      state = state.copyWith(progress: 0.7);

      // ایجاد نام نشست از نام فایل + تاریخ
      final now = DateTime.now();
      final sessionName =
          '${state.selectedFileName ?? 'برداشت'} - ${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // ایجاد نشست برداشت
      final success = await _pickingNotifier.createNewSession(
        name: sessionName,
        sourceFile: state.selectedFileName ?? state.selectedFilePath!,
        items: items,
      );

      // پیشرفت ۱۰۰٪
      state = state.copyWith(progress: 1.0);

      if (success) {
        state = state.copyWith(
          isLoading: false,
          result: ImportResult(
            totalRecords: items.length,
            importedCount: items.length,
            skippedCount: 0,
            errorCount: 0,
            fileName: state.selectedFileName ?? '',
          ),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'خطا در ایجاد نشست برداشت',
        );
      }
    } on ImportFileException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در Import: $e',
      );
    }
  }

  /// پاک کردن انتخاب
  void clearSelection() {
    state = ImportState.initial();
  }
}

/// Provider برای ImportNotifier
final importProvider = StateNotifierProvider<ImportNotifier, ImportState>((ref) {
  return ImportNotifier(
    ref.watch(importBarcodesUseCaseProvider),
    ref.watch(importExportRepositoryProvider) as ImportExportRepositoryImpl,
    ref.watch(authStateProvider),
    ref.watch(pickingProvider.notifier),
  );
});
