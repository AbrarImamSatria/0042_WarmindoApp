part of 'report_bloc.dart';

@immutable
sealed class ReportState {}

// Initial state
final class ReportInitial extends ReportState {}

// Loading state
final class ReportLoading extends ReportState {}

// Dashboard loaded
final class ReportDashboardLoaded extends ReportState {
  final Map<String, dynamic> data;

  ReportDashboardLoaded({required this.data});
}

// Revenue loaded
final class ReportRevenueLoaded extends ReportState {
  final double totalRevenue;
  final RevenuePeriod period;
  final List<Map<String, dynamic>>? dailyRevenue;

  ReportRevenueLoaded({
    required this.totalRevenue,
    required this.period,
    this.dailyRevenue,
  });
}

// Best selling loaded
final class ReportBestSellingLoaded extends ReportState {
  final List<Map<String, dynamic>> items;

  ReportBestSellingLoaded({required this.items});
}

// Payment stats loaded
final class ReportPaymentStatsLoaded extends ReportState {
  final Map<String, dynamic> stats;

  ReportPaymentStatsLoaded({required this.stats});
}

// Export ready
final class ReportExportReady extends ReportState {
  final List<TransaksiModel> transactions;
  final List<Map<String, dynamic>> salesByMenu;
  final List<Map<String, dynamic>> dailyRevenue;
  final DateTime startDate;
  final DateTime endDate;

  ReportExportReady({
    required this.transactions,
    required this.salesByMenu,
    required this.dailyRevenue,
    required this.startDate,
    required this.endDate,
  });
}

// Failure state
final class ReportFailure extends ReportState {
  final String error;

  ReportFailure({required this.error});
}