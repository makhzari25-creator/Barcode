// lib/features/picking/presentation/providers/picking_provider.dart
//
// Provider برای مدیریت وضعیت نشست برداشت
//

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/picking_item.dart';
import '../../domain/entities/picking_session.dart';
import '../../domain/usecases/picking_usecases.dart';

/// وضعیت صفحه برداشت
@immutable
class PickingState {
  /// نشست فعال
  final PickingSession? activeSession;

  /// آیتم فعلی که باید برداشت شود
  final PickingItem? currentItem;

  /// همه آیتم‌های نشست (در صورت نیاز)
  final List<PickingItem> allItems;

  /// ایندکس آیتم فعلی (۰-based)
  final int currentIndex;

  /// در حال بارگذاری؟
  final bool isLoading;

  /// در حال پردازش اسکن؟
  final bool isProcessing;

  /// آخرین نتیجه اعتبارسنجی
  final PickingValidationStatus? lastValidationStatus;

  /// پیام خطا
  final String? errorMessage;

  /// آیا نشست تکمیل شده؟
  final bool isCompleted;

  const PickingState({
    this.activeSession,
    this.currentItem,
    this.allItems = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.isProcessing = false,
    this.lastValidationStatus,
    this.errorMessage,
    this.isCompleted = false,
  });

  /// تعداد کل آیتم‌ها
  int get totalItems => activeSession?.totalItems ?? 0;

  /// تعداد آیتم‌های برداشت شده
  int get pickedCount => activeSession?.pickedCount ?? 0;

  /// تعداد آیتم‌های باقی‌مانده
  int get remainingCount => totalItems - pickedCount - (activeSession?.skippedCount ?? 0);

  /// درصد پیشرفت (۰ تا ۱)
  double get progress {
    if (totalItems == 0) return 0;
    return (pickedCount + (activeSession?.skippedCount ?? 0)) / totalItems;
  }

  /// شماره آیتم فعلی (۱-based برای نمایش)
  int get displayCurrentNumber => currentIndex + 1;

  PickingState copyWith({
    PickingSession? activeSession,
    PickingItem? currentItem,
    List<PickingItem>? allItems,
    int? currentIndex,
    bool? isLoading,
    bool? isProcessing,
    PickingValidationStatus? lastValidationStatus,
    String? errorMessage,
    bool? isCompleted,
  }) {
    return PickingState(
      activeSession: activeSession ?? this.activeSession,
      currentItem: currentItem ?? this.currentItem,
      allItems: allItems ?? this.allItems,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      lastValidationStatus: lastValidationStatus ?? this.lastValidationStatus,
      errorMessage: errorMessage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory PickingState.initial() => const PickingState();
}

/// State Notifier برای مدیریت نشست برداشت
class PickingNotifier extends StateNotifier<PickingState> {
  final CreatePickingSessionUseCase _createSessionUseCase;
  final GetActiveSessionUseCase _getActiveSessionUseCase;
  final GetUserSessionsUseCase _getUserSessionsUseCase;
  final GetAllSessionsUseCase _getAllSessionsUseCase;
  final GetSessionItemsUseCase _getSessionItemsUseCase;
  final GetNextPendingItemUseCase _getNextPendingItemUseCase;
  final ValidatePickingBarcodeUseCase _validateBarcodeUseCase;
  final PickItemUseCase _pickItemUseCase;
  final SkipItemUseCase _skipItemUseCase;
  final MarkWrongBarcodeUseCase _markWrongBarcodeUseCase;
  final CompleteSessionUseCase _completeSessionUseCase;
  final CancelSessionUseCase _cancelSessionUseCase;
  final DeleteSessionUseCase _deleteSessionUseCase;
  final GetSessionStatsUseCase _getSessionStatsUseCase;
  final AuthState _authState;

  PickingNotifier(
    this._createSessionUseCase,
    this._getActiveSessionUseCase,
    this._getUserSessionsUseCase,
    this._getAllSessionsUseCase,
    this._getSessionItemsUseCase,
    this._getNextPendingItemUseCase,
    this._validateBarcodeUseCase,
    this._pickItemUseCase,
    this._skipItemUseCase,
    this._markWrongBarcodeUseCase,
    this._completeSessionUseCase,
    this._cancelSessionUseCase,
    this._deleteSessionUseCase,
    this._getSessionStatsUseCase,
    this._authState,
  ) : super(PickingState.initial()) {
    // در صورت وجود نشست فعال، آن را بارگذاری کن
    _loadActiveSession();
  }

  /// بارگذاری نشست فعال کاربر
  Future<void> _loadActiveSession() async {
    if (!_authState.isAuthenticated || _authState.user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final session = await _getActiveSessionUseCase(_authState.user!.id!);
      if (session != null) {
        // بارگذاری آیتم‌های نشست
        final itemsResult = await _getSessionItemsUseCase(session.id!);
        final items = itemsResult.getOrNull() ?? [];

        // پیدا کردن آیتم فعلی (اولین pending)
        final currentItem = items.where((i) => i.isPending).firstOrNull;
        final currentIndex = currentItem != null
            ? items.indexWhere((i) => i.id == currentItem.id)
            : items.length;

        state = state.copyWith(
          activeSession: session,
          allItems: items,
          currentItem: currentItem,
          currentIndex: currentIndex >= 0 ? currentIndex : 0,
          isLoading: false,
          isCompleted: currentItem == null,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در بارگذاری نشست: $e',
      );
    }
  }

  /// ایجاد نشست برداشت جدید
  Future<bool> createNewSession({
    required String name,
    required String sourceFile,
    required List<PickingItem> items,
  }) async {
    if (!_authState.isAuthenticated || _authState.user == null) {
      state = state.copyWith(errorMessage: 'کاربر وارد نشده است');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _createSessionUseCase(
        userId: _authState.user!.id!,
        name: name,
        sourceFile: sourceFile,
        items: items,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (session) async {
          // بارگذاری آیتم اول
          final itemsResult = await _getSessionItemsUseCase(session.id!);
          final allItems = itemsResult.getOrNull() ?? [];

          state = state.copyWith(
            activeSession: session,
            allItems: allItems,
            currentItem: allItems.isNotEmpty ? allItems.first : null,
            currentIndex: 0,
            isLoading: false,
            isCompleted: allItems.isEmpty,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در ایجاد نشست: $e',
      );
      return false;
    }
  }

  /// پردازش بارکد اسکن‌شده
  ///
  /// خروجی: وضعیت نتیجه اعتبارسنجی
  Future<PickingValidationStatus> processScannedBarcode(String code) async {
    if (state.activeSession == null || state.currentItem == null) {
      return PickingValidationStatus.notInList;
    }

    if (state.isProcessing) {
      return state.lastValidationStatus ?? PickingValidationStatus.notInList;
    }

    state = state.copyWith(isProcessing: true);

    try {
      final result = await _validateBarcodeUseCase(
        sessionId: state.activeSession!.id!,
        scannedBarcode: code,
        currentItem: state.currentItem,
      );

      switch (result.status) {
        case PickingValidationStatus.correct:
          // ثبت موفقیت برداشت
          await _pickItemUseCase(
            result.matchedItem!,
            scannedBarcode: code,
          );
          // به‌روزرسانی نشست
          await _refreshSession();
          // رفتن به آیتم بعدی
          await _advanceToNextItem();
          break;

        case PickingValidationStatus.wrongItem:
          // آیتم اشتباه - ثبت به‌عنوان wrongBarcode برای آیتم فعلی
          if (state.currentItem != null) {
            await _markWrongBarcodeUseCase(
              state.currentItem!,
              wrongBarcode: code,
            );
          }
          break;

        case PickingValidationStatus.notInList:
        case PickingValidationStatus.alreadyPicked:
          // فقط نمایش خطا - هیچ تغییری در دیتابیس
          break;
      }

      state = state.copyWith(
        isProcessing: false,
        lastValidationStatus: result.status,
      );

      return result.status;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'خطا در پردازش: $e',
        lastValidationStatus: PickingValidationStatus.notInList,
      );
      return PickingValidationStatus.notInList;
    }
  }

  /// نادیده گرفتن آیتم فعلی و رفتن به بعدی
  Future<void> skipCurrentItem() async {
    if (state.currentItem == null) return;

    state = state.copyWith(isProcessing: true);

    try {
      await _skipItemUseCase(state.currentItem!);
      await _refreshSession();
      await _advanceToNextItem();
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'خطا در نادیده گرفتن: $e',
      );
    }
  }

  /// رفتن به آیمن بعدی (دستی)
  Future<void> goToNextItem() async {
    await _advanceToNextItem();
  }

  /// تکمیل نشست
  Future<bool> completeSession() async {
    if (state.activeSession == null) return false;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _completeSessionUseCase(state.activeSession!.id!);
      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (session) {
          state = state.copyWith(
            activeSession: session,
            isLoading: false,
            isCompleted: true,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در تکمیل نشست: $e',
      );
      return false;
    }
  }

  /// لغو نشست
  Future<bool> cancelSession() async {
    if (state.activeSession == null) return false;

    try {
      final result = await _cancelSessionUseCase(state.activeSession!.id!);
      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
          return false;
        },
        (_) {
          state = PickingState.initial();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطا در لغو نشست: $e');
      return false;
    }
  }

  /// پاک کردن آخرین نتیجه اعتبارسنجی
  void clearLastValidation() {
    state = state.copyWith(lastValidationStatus: null);
  }

  /// پاک کردن پیام خطا
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  // ============ Private Helpers ============

  /// به‌روزرسانی نشست از دیتابیس
  Future<void> _refreshSession() async {
    if (state.activeSession == null) return;

    try {
      final result = await _getSessionItemsUseCase(state.activeSession!.id!);
      final items = result.getOrNull() ?? [];

      // محاسبه مجدد شمارنده‌ها
      int picked = 0;
      int skipped = 0;
      for (final item in items) {
        if (item.isPicked) {
          picked++;
        } else if (item.isMissed) {
          skipped++;
        }
      }

      final updatedSession = state.activeSession!.copyWith(
        pickedCount: picked,
        skippedCount: skipped,
      );

      state = state.copyWith(
        activeSession: updatedSession,
        allItems: items,
      );
    } catch (_) {}
  }

  /// رفتن به آیتم بعدی pending
  Future<void> _advanceToNextItem() async {
    if (state.activeSession == null) return;

    try {
      // پیدا کردن آیتم بعدی pending از دیتابیس
      final nextItem =
          await _getNextPendingItemUseCase(state.activeSession!.id!);

      if (nextItem == null) {
        // همه آیتم‌ها پردازش شده‌اند
        state = state.copyWith(
          currentItem: null,
          isCompleted: true,
        );
      } else {
        // پیدا کردن ایندکس آیتم بعدی
        int nextIndex = 0;
        if (state.allItems.isNotEmpty) {
          final idx =
              state.allItems.indexWhere((i) => i.id == nextItem.id);
          if (idx >= 0) {
            nextIndex = idx;
          }
        }

        state = state.copyWith(
          currentItem: nextItem,
          currentIndex: nextIndex,
          lastValidationStatus: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'خطا در رفتن به آیتم بعدی: $e',
      );
    }
  }
}

/// Provider برای PickingNotifier
final pickingProvider =
    StateNotifierProvider<PickingNotifier, PickingState>((ref) {
  return PickingNotifier(
    ref.watch(createPickingSessionUseCaseProvider),
    ref.watch(getActiveSessionUseCaseProvider),
    ref.watch(getUserSessionsUseCaseProvider),
    ref.watch(getAllSessionsUseCaseProvider),
    ref.watch(getSessionItemsUseCaseProvider),
    ref.watch(getNextPendingItemUseCaseProvider),
    ref.watch(validatePickingBarcodeUseCaseProvider),
    ref.watch(pickItemUseCaseProvider),
    ref.watch(skipItemUseCaseProvider),
    ref.watch(markWrongBarcodeUseCaseProvider),
    ref.watch(completeSessionUseCaseProvider),
    ref.watch(cancelSessionUseCaseProvider),
    ref.watch(deleteSessionUseCaseProvider),
    ref.watch(getSessionStatsUseCaseProvider),
    ref.watch(authStateProvider),
  );
});

/// Provider برای دسترسی به Use Case آمار نشست
final sessionStatsProvider =
    FutureProvider.family<PickingSessionStats?, int>((ref, sessionId) async {
  final useCase = ref.watch(getSessionStatsUseCaseProvider);
  final result = await useCase(sessionId);
  return result.getOrNull();
});
