

import 'package:warmindo_app/data/datasource/item_transaksi_dao.dart';
import 'package:warmindo_app/data/datasource/transaksi_dao.dart';
import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';

class TransaksiRepository {
  final TransaksiDao _transaksiDao = TransaksiDao();
  final ItemTransaksiDao _itemTransaksiDao = ItemTransaksiDao();

  // Create transaksi with items
  Future<int> createTransaksi(
    TransaksiModel transaksi,
    List<ItemTransaksiModel> items,
  ) async {
    try {
      if (items.isEmpty) {
        throw Exception('Transaksi harus memiliki minimal 1 item');
      }

      // Calculate total from items
      double total = 0;
      for (var item in items) {
        total += item.harga * item.jumlah;
      }

      // Update transaksi total
      final updatedTransaksi = transaksi.copyWith(totalBayar: total);

      // Insert transaksi with items
      return await _transaksiDao.insertWithItems(updatedTransaksi, items);
    } catch (e) {
      throw Exception('Gagal membuat transaksi: ${e.toString()}');
    }
  }

  // Get transaksi by ID with items
  Future<Map<String, dynamic>?> getTransaksiDetail(int id) async {
    try {
      final transaksi = await _transaksiDao.getById(id);
      if (transaksi == null) return null;

      final items = await _itemTransaksiDao.getByTransaksiId(id);

      return {
        'transaksi': transaksi,
        'items': items,
      };
    } catch (e) {
      throw Exception('Gagal mengambil detail transaksi: ${e.toString()}');
    }
  }

  // Get all transaksi
  Future<List<TransaksiModel>> getAllTransaksi() async {
    try {
      return await _transaksiDao.getAll();
    } catch (e) {
      throw Exception('Gagal mengambil daftar transaksi: ${e.toString()}');
    }
  }

  // Get transaksi hari ini
  Future<List<TransaksiModel>> getTransaksiHariIni() async {
    try {
      return await _transaksiDao.getTodayTransactions();
    } catch (e) {
      throw Exception('Gagal mengambil transaksi hari ini: ${e.toString()}');
    }
  }

  // Get transaksi by date range
  Future<List<TransaksiModel>> getTransaksiByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transaksiDao.getByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('Gagal mengambil transaksi: ${e.toString()}');
    }
  }

  // Get transaksi by user (for employee, only today)
  Future<List<TransaksiModel>> getTransaksiByUser(int userId, String role) async {
    try {
      if (role == 'karyawan') {
        // Karyawan hanya bisa lihat transaksi hari ini
        final todayTransactions = await _transaksiDao.getTodayTransactions();
        return todayTransactions.where((t) => t.idPengguna == userId).toList();
      } else {
        // Pemilik bisa lihat semua transaksi user
        return await _transaksiDao.getByUser(userId);
      }
    } catch (e) {
      throw Exception('Gagal mengambil transaksi user: ${e.toString()}');
    }
  }

  // Get pendapatan hari ini
  Future<double> getPendapatanHariIni() async {
    try {
      return await _transaksiDao.getTotalPendapatanHariIni();
    } catch (e) {
      throw Exception('Gagal mengambil pendapatan hari ini: ${e.toString()}');
    }
  }

  // Get pendapatan bulan ini
  Future<double> getPendapatanBulanIni() async {
    try {
      return await _transaksiDao.getTotalPendapatanBulanIni();
    } catch (e) {
      throw Exception('Gagal mengambil pendapatan bulan ini: ${e.toString()}');
    }
  }

  // Get pendapatan by date range
  Future<double> getPendapatanByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transaksiDao.getTotalPendapatanByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('Gagal mengambil pendapatan: ${e.toString()}');
    }
  }

  // Get daily revenue report
  Future<List<Map<String, dynamic>>> getDailyRevenueReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transaksiDao.getDailyRevenue(startDate, endDate);
    } catch (e) {
      throw Exception('Gagal mengambil laporan harian: ${e.toString()}');
    }
  }

  // Get payment method statistics
  Future<Map<String, dynamic>> getPaymentMethodStatistics() async {
    try {
      return await _transaksiDao.getPaymentMethodStats();
    } catch (e) {
      throw Exception('Gagal mengambil statistik pembayaran: ${e.toString()}');
    }
  }

  // Get best selling items
  Future<List<Map<String, dynamic>>> getBestSellingItems({int limit = 10}) async {
    try {
      return await _itemTransaksiDao.getBestSellingItems(limit: limit);
    } catch (e) {
      throw Exception('Gagal mengambil menu terlaris: ${e.toString()}');
    }
  }

  // Get sales by menu item
  Future<List<Map<String, dynamic>>> getSalesByMenuItem(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _itemTransaksiDao.getSalesByMenuItem(startDate, endDate);
    } catch (e) {
      throw Exception('Gagal mengambil penjualan per menu: ${e.toString()}');
    }
  }

  // Delete transaksi (only for owner)
  Future<bool> deleteTransaksi(int id) async {
    try {
      final result = await _transaksiDao.delete(id);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: ${e.toString()}');
    }
  }

  // Get summary for dashboard
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final pendapatanHariIni = await getPendapatanHariIni();
      final pendapatanBulanIni = await getPendapatanBulanIni();
      final transaksiHariIni = await getTransaksiHariIni();
      final paymentStats = await getPaymentMethodStatistics();
      final bestSelling = await getBestSellingItems(limit: 5);

      return {
        'pendapatanHariIni': pendapatanHariIni,
        'pendapatanBulanIni': pendapatanBulanIni,
        'jumlahTransaksiHariIni': transaksiHariIni.length,
        'paymentStats': paymentStats,
        'bestSelling': bestSelling,
      };
    } catch (e) {
      throw Exception('Gagal mengambil summary dashboard: ${e.toString()}');
    }
  }
}