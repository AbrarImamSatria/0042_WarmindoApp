part of 'report_bloc.dart';

enum RevenuePeriod { today, month, custom }

@immutable
sealed class ReportEvent {}

// Load dashboard summary
final class ReportLoadDashboard extends ReportEvent {}

// Load revenue report
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

// Load best selling items
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

// Load payment method statistics
final class ReportLoadPaymentStats extends ReportEvent {}

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