// bloc/report/report_event.dart (UPDATED)
part of 'report_bloc.dart';

enum RevenuePeriod { today, month, custom }

@immutable
sealed class ReportEvent {}

// Load dashboard summary
final class ReportLoadDashboard extends ReportEvent {}

// ✅ UPDATED: Load revenue report with date range
final class ReportLoadRevenue extends ReportEvent {
  final RevenuePeriod period;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeDailyBreakdown;

  ReportLoadRevenue({
    required this.period,
    this.startDate,
    this.endDate,
    this.includeDailyBreakdown = false,
  });
}

// ✅ UPDATED: Load best selling items with date range
final class ReportLoadBestSelling extends ReportEvent {
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;

  ReportLoadBestSelling({
    this.limit = 10,
    this.startDate,
    this.endDate,
  });
}

// ✅ UPDATED: Load payment method statistics with date range
final class ReportLoadPaymentStats extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  ReportLoadPaymentStats({
    this.startDate,
    this.endDate,
  });
}

// ✅ NEW: Load dashboard with date range
final class ReportLoadDashboardWithDateRange extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  ReportLoadDashboardWithDateRange({
    this.startDate,
    this.endDate,
  });
}

// Export data
final class ReportExportData extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  ReportExportData({
    required this.startDate,
    required this.endDate,
  });
}

// Generate Excel file
final class ReportGenerateExcel extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  final bool includeTransactions;
  final bool includeSalesByMenu;
  final bool includeDailyRevenue;
  final bool includePaymentStats;

  ReportGenerateExcel({
    required this.startDate,
    required this.endDate,
    this.includeTransactions = true,
    this.includeSalesByMenu = true,
    this.includeDailyRevenue = true,
    this.includePaymentStats = true,
  });
}

// Generate PDF file
final class ReportGeneratePDF extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  final bool includeTransactions;
  final bool includeSalesByMenu;
  final bool includePaymentStats;

  ReportGeneratePDF({
    required this.startDate,
    required this.endDate,
    this.includeTransactions = true,
    this.includeSalesByMenu = true,
    this.includePaymentStats = true,
  });
}