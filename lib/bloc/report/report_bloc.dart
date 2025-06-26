import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/data/repository/item_transaksi_repository.dart';
import 'package:warmindo_app/data/repository/transaksi_repository.dart';
import '../auth/auth_bloc.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final TransaksiRepository _transaksiRepository = TransaksiRepository();
  final ItemTransaksiRepository _itemTransaksiRepository = ItemTransaksiRepository();
  final AuthBloc _authBloc;

  ReportBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(ReportInitial()) {
    on<ReportLoadDashboard>(_onLoadDashboard);
    on<ReportLoadRevenue>(_onLoadRevenue);
    on<ReportLoadBestSelling>(_onLoadBestSelling);
    on<ReportLoadPaymentStats>(_onLoadPaymentStats);
    on<ReportExportData>(_onExportData);
  }

  // Check owner permission
  bool _checkOwnerPermission() {
    return _authBloc.isOwner;
  }

  // Load dashboard summary
  Future<void> _onLoadDashboard(ReportLoadDashboard event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat laporan'));
      return;
    }

    emit(ReportLoading());
    try {
      final summary = await _transaksiRepository.getDashboardSummary();
      emit(ReportDashboardLoaded(data: summary));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Load revenue report
  Future<void> _onLoadRevenue(ReportLoadRevenue event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat laporan pendapatan'));
      return;
    }

    emit(ReportLoading());
    try {
      double revenue;
      
      switch (event.period) {
        case RevenuePeriod.today:
          revenue = await _transaksiRepository.getPendapatanHariIni();
          break;
        case RevenuePeriod.month:
          revenue = await _transaksiRepository.getPendapatanBulanIni();
          break;
        case RevenuePeriod.custom:
          if (event.startDate != null && event.endDate != null) {
            revenue = await _transaksiRepository.getPendapatanByDateRange(
              event.startDate!,
              event.endDate!,
            );
          } else {
            throw Exception('Tanggal harus diisi untuk periode custom');
          }
          break;
      }

      // Get daily revenue if needed
      List<Map<String, dynamic>>? dailyRevenue;
      if (event.includeDailyBreakdown && event.startDate != null && event.endDate != null) {
        dailyRevenue = await _transaksiRepository.getDailyRevenueReport(
          event.startDate!,
          event.endDate!,
        );
      }

      emit(ReportRevenueLoaded(
        totalRevenue: revenue,
        period: event.period,
        dailyRevenue: dailyRevenue,
      ));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Load best selling items
  Future<void> _onLoadBestSelling(ReportLoadBestSelling event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat laporan menu terlaris'));
      return;
    }

    emit(ReportLoading());
    try {
      final bestSelling = await _itemTransaksiRepository.getBestSellingItems(
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(ReportBestSellingLoaded(items: bestSelling));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Load payment method statistics
  Future<void> _onLoadPaymentStats(ReportLoadPaymentStats event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat statistik pembayaran'));
      return;
    }

    emit(ReportLoading());
    try {
      final stats = await _transaksiRepository.getPaymentMethodStatistics();
      emit(ReportPaymentStatsLoaded(stats: stats));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Export data for Excel
  Future<void> _onExportData(ReportExportData event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat export data'));
      return;
    }

    emit(ReportLoading());
    try {
      // Get all required data
      final transactions = await _transaksiRepository.getTransaksiByDateRange(
        event.startDate,
        event.endDate,
      );
      
      final salesByMenu = await _itemTransaksiRepository.getItemsForExport(
        event.startDate,
        event.endDate,
      );
      
      final dailyRevenue = await _transaksiRepository.getDailyRevenueReport(
        event.startDate,
        event.endDate,
      );

      emit(ReportExportReady(
        transactions: transactions,
        salesByMenu: salesByMenu,
        dailyRevenue: dailyRevenue,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }
}