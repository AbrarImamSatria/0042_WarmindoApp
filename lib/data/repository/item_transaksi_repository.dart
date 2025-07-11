import 'package:warmindo_app/data/datasource/item_transaksi_dao.dart';
import 'package:warmindo_app/data/model/item_transaksi_model.dart';

class ItemTransaksiRepository {
  final ItemTransaksiDao _itemTransaksiDao = ItemTransaksiDao();

  // Get items by transaksi ID
  Future<List<ItemTransaksiModel>> getItemsByTransaksiId(
    int transaksiId,
  ) async {
    try {
      return await _itemTransaksiDao.getByTransaksiId(transaksiId);
    } catch (e) {
      throw Exception('Gagal mengambil item transaksi: ${e.toString()}');
    }
  }

  // Get items sold today
  Future<List<Map<String, dynamic>>> getItemsSoldToday() async {
    try {
      return await _itemTransaksiDao.getItemsSoldToday();
    } catch (e) {
      throw Exception('Gagal mengambil item terjual hari ini: ${e.toString()}');
    }
  }

  // Get best selling items
  Future<List<Map<String, dynamic>>> getBestSellingItems({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (startDate != null && endDate != null) {
        return await _itemTransaksiDao.getSalesByMenuItem(startDate, endDate);
      } else {
        return await _itemTransaksiDao.getBestSellingItems(limit: limit);
      }
    } catch (e) {
      throw Exception('Gagal mengambil menu terlaris: ${e.toString()}');
    }
  }

  // Get sales report by menu item
  Future<List<Map<String, dynamic>>> getSalesReportByMenuItem(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _itemTransaksiDao.getSalesByMenuItem(startDate, endDate);
    } catch (e) {
      throw Exception('Gagal mengambil laporan penjualan: ${e.toString()}');
    }
  }

  // Get menu performance (for analysis)
  Future<Map<String, dynamic>> getMenuPerformance(String namaMenu) async {
    try {
      final allItems = await _itemTransaksiDao.getAll();

      // Filter by menu name
      final menuItems = allItems
          .where((item) => item.namaMenu == namaMenu)
          .toList();

      if (menuItems.isEmpty) {
        return {
          'totalQuantity': 0,
          'totalRevenue': 0.0,
          'averagePrice': 0.0,
          'transactionCount': 0,
        };
      }

      // Calculate statistics
      int totalQuantity = 0;
      double totalRevenue = 0;
      Set<int> uniqueTransactions = {};

      for (var item in menuItems) {
        totalQuantity += item.jumlah;
        totalRevenue += item.subtotal;
        uniqueTransactions.add(item.idTransaksi);
      }

      return {
        'totalQuantity': totalQuantity,
        'totalRevenue': totalRevenue,
        'averagePrice': totalRevenue / totalQuantity,
        'transactionCount': uniqueTransactions.length,
      };
    } catch (e) {
      throw Exception('Gagal mengambil performa menu: ${e.toString()}');
    }
  }

  // Get category performance
  Future<Map<String, Map<String, dynamic>>> getCategoryPerformance(
    List<String> menuByCategory,
    String category,
  ) async {
    try {
      Map<String, Map<String, dynamic>> result = {};

      for (String menuName in menuByCategory) {
        result[menuName] = await getMenuPerformance(menuName);
      }

      return result;
    } catch (e) {
      throw Exception('Gagal mengambil performa kategori: ${e.toString()}');
    }
  }

  // For export data - get all items with date range
  Future<List<Map<String, dynamic>>> getItemsForExport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final items = await _itemTransaksiDao.getSalesByMenuItem(
        startDate,
        endDate,
      );

      // Add additional formatting for export
      return items.map((item) {
        return {
          'Nama Menu': item['nama_menu'],
          'Total Terjual': item['total_quantity'],
          'Total Pendapatan': 'Rp ${item['total_revenue'].toStringAsFixed(0)}',
          'Harga Rata-rata': 'Rp ${item['average_price'].toStringAsFixed(0)}',
        };
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data untuk export: ${e.toString()}');
    }
  }

  // Check if menu has been sold (before deleting menu)
  Future<bool> isMenuEverSold(String namaMenu) async {
    try {
      final allItems = await _itemTransaksiDao.getAll();
      return allItems.any((item) => item.namaMenu == namaMenu);
    } catch (e) {
      throw Exception('Gagal mengecek history penjualan menu: ${e.toString()}');
    }
  }
}
