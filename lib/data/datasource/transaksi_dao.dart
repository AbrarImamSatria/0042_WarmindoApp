import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'database_helper.dart';

class TransaksiDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Insert transaksi baru dengan items (dalam transaction)
  Future<int> insertWithItems(TransaksiModel transaksi, List<ItemTransaksiModel> items) async {
    final db = await _databaseHelper.database;
    int transaksiId = 0;

    await db.transaction((txn) async {
      // Insert transaksi header
      transaksiId = await txn.insert(
        DatabaseHelper.tableTransaksi,
        transaksi.toMapForInsert(),
      );

      // Insert transaksi items
      for (var item in items) {
        await txn.insert(
          DatabaseHelper.tableItemTransaksi,
          item.copyWith(idTransaksi: transaksiId).toMapForInsert(),
        );
      }
    });

    return transaksiId;
  }

  // Get transaksi by ID
  Future<TransaksiModel?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTransaksi,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TransaksiModel.fromMap(maps.first);
  }

  // Get all transaksi
  Future<List<TransaksiModel>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTransaksi,
      orderBy: 'tanggal DESC',
    );

    return List.generate(maps.length, (i) {
      return TransaksiModel.fromMap(maps[i]);
    });
  }

  // Get transaksi by date range
  Future<List<TransaksiModel>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTransaksi,
      where: 'DATE(tanggal) BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'tanggal DESC',
    );

    return List.generate(maps.length, (i) {
      return TransaksiModel.fromMap(maps[i]);
    });
  }

  // Get transaksi hari ini
  Future<List<TransaksiModel>> getTodayTransactions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getByDateRange(startOfDay, endOfDay);
  }

  // Get transaksi by user
  Future<List<TransaksiModel>> getByUser(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTransaksi,
      where: 'id_pengguna = ?',
      whereArgs: [userId],
      orderBy: 'tanggal DESC',
    );

    return List.generate(maps.length, (i) {
      return TransaksiModel.fromMap(maps[i]);
    });
  }

  // Get transaksi by payment method
  Future<List<TransaksiModel>> getByPaymentMethod(String metodeBayar) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTransaksi,
      where: 'metode_bayar = ?',
      whereArgs: [metodeBayar],
      orderBy: 'tanggal DESC',
    );

    return List.generate(maps.length, (i) {
      return TransaksiModel.fromMap(maps[i]);
    });
  }

  // Get total pendapatan hari ini
  Future<double> getTotalPendapatanHariIni() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_bayar) as total 
      FROM ${DatabaseHelper.tableTransaksi} 
      WHERE DATE(tanggal) = DATE('now', 'localtime')
    ''');

    return result.first['total'] as double? ?? 0.0;
  }

  // Get total pendapatan bulan ini
  Future<double> getTotalPendapatanBulanIni() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_bayar) as total 
      FROM ${DatabaseHelper.tableTransaksi} 
      WHERE strftime('%Y-%m', tanggal) = strftime('%Y-%m', 'now', 'localtime')
    ''');

    return result.first['total'] as double? ?? 0.0;
  }

  // Get total pendapatan by date range
  Future<double> getTotalPendapatanByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_bayar) as total 
      FROM ${DatabaseHelper.tableTransaksi} 
      WHERE DATE(tanggal) BETWEEN ? AND ?
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    return result.first['total'] as double? ?? 0.0;
  }

  // Get pendapatan per hari dalam range
  Future<List<Map<String, dynamic>>> getDailyRevenue(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        DATE(tanggal) as date,
        COUNT(*) as transaction_count,
        SUM(total_bayar) as total
      FROM ${DatabaseHelper.tableTransaksi}
      WHERE DATE(tanggal) BETWEEN ? AND ?
      GROUP BY DATE(tanggal)
      ORDER BY date DESC
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);
  }

  // Get statistik by payment method
  Future<Map<String, dynamic>> getPaymentMethodStats() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        metode_bayar,
        COUNT(*) as count,
        SUM(total_bayar) as total
      FROM ${DatabaseHelper.tableTransaksi}
      GROUP BY metode_bayar
    ''');

    Map<String, dynamic> stats = {};
    for (var row in result) {
      stats[row['metode_bayar'] as String] = {
        'count': row['count'],
        'total': row['total'],
      };
    }
    return stats;
  }

  // Delete transaksi (akan otomatis delete items karena CASCADE)
  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableTransaksi,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}