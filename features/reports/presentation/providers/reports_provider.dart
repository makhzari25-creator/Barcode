import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../scanner/domain/entities/scan_record.dart';
import '../../../scanner/domain/usecases/scan_usecases.dart';

/// وضعیت صفحه گزارش‌ها
@immutable
class ReportsState {
  final bool isLoading;
  final ScanStats? stats;
  final List<ScanRecord> scans;
  final String? startDate;
  final String? endDate;
  final int? selectedUserId;
  final String? errorMessage;

  const ReportsState({
    this.isLoading = false,
    this.stats,
    this.scans = const [],
    this.startDate,
    this.endDate,
    this.selectedUserId,
    this.errorMessage,
  });

  ReportsState copyWith({
    bool? isLoading,
    ScanStats? stats,
    List<ScanRecord>? scans,
    String? startDate,
    String? endDate,
    int? selectedUserId,
    String? errorMessage,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      scans: scans ?? this.scans,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      errorMessage: errorMessage,
    );
  }

  factory ReportsState.initial() => const ReportsState();
}

/// State Notifier برای گزارش‌ها
class ReportsNotifier extends StateNotifier<ReportsState> {
  final GetScanStatsUseCase _getStats;
  final GetScansUseCase _getScans;
  final AuthState _authState;

  ReportsNotifier(this._getStats, this._getScans, this._authState)
      : super(ReportsState.initial()) {
    _loadData();
  }

  /// بارگذاری آمار و اسکن‌ها
  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      // اپراتور فقط اسکن‌های خود را می‌بیند
      final userId = _authState.user?.role.isOperator == true
          ? _authState.user?.id
          : state.selectedUserId;

      final statsResult = await _getStats(
        startDate: state.startDate,
        endDate: state.endDate,
        userId: userId,
      );

      final scansResult = await _getScans(
        startDate: state.startDate,
        endDate: state.endDate,
        userId: userId,
        limit: 100,
      );

      state = state.copyWith(
        isLoading: false,
        stats: statsResult.getOrNull(),
        scans: scansResult.getOrNull() ?? [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'خطا در بارگذاری داده‌ها: $e',
      );
    }
  }

  /// تنظیم فیلتر تاریخ شروع
  void setStartDate(String? date) {
    state = state.copyWith(startDate: date);
    _loadData();
  }

  /// تنظیم فیلتر تاریخ پایان
  void setEndDate(String? date) {
    state = state.copyWith(endDate: date);
    _loadData();
  }

  /// تنظیم فیلتر اپراتور (فقط مدیر)
  void setSelectedUser(int? userId) {
    state = state.copyWith(selectedUserId: userId);
    _loadData();
  }

  /// پاک کردن فیلترها
  void clearFilters() {
    state = ReportsState.initial();
    _loadData();
  }

  /// بارگذاری مجدد
  Future<void> refresh() => _loadData();
}

/// Provider برای ReportsNotifier
final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(
    ref.watch(getScanStatsUseCaseProvider),
    ref.watch(getScansUseCaseProvider),
    ref.watch(authStateProvider),
  );
});
