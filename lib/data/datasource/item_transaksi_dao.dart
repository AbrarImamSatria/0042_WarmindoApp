import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'database_helper.dart';

class ItemTransaksiDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Insert item transaksi
  Future<int> insert(ItemTransaksiModel item) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tableItemTransaksi,
      item.toMapForInsert(),
    );
  }

  // Insert multiple items
  Future<void> insertBatch(List<ItemTransaksiModel> items) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();
    
    for (var item in items) {
      batch.insert(
        DatabaseHelper.tableItemTransaksi,
        item.toMapForInsert(),
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Get items by transaksi ID
  Future<List<ItemTransaksiModel>> getByTransaksiId(int transaksiId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItemTransaksi,
      where: 'id_transaksi = ?',
      whereArgs: [transaksiId],
      orderBy: 'id ASC',
    );

    return List.generate(maps.length, (i) {
      return ItemTransaksiModel.fromMap(maps[i]);
    });
  }

  // Get all items
  Future<List<ItemTransaksiModel>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableItemTransaksi,
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return ItemTransaksiModel.fromMap(maps[i]);
    });
  }

  // Get best selling items
  Future<List<Map<String, dynamic>>> getBestSellingItems({int limit = 10}) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        nama_menu,
        SUM(jumlah) as total_quantity,
        COUNT(DISTINCT id_transaksi) as transaction_count,
        SUM(jumlah * harga) as total_revenue
      FROM ${DatabaseHelper.tableItemTransaksi}
      GROUP BY nama_menu
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [limit]);
  }

  // Get items sold today
  Future<List<Map<String, dynamic>>> getItemsSoldToday() async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        it.nama_menu,
        SUM(it.jumlah) as quantity,
        SUM(it.jumlah * it.harga) as total
      FROM ${DatabaseHelper.tableItemTransaksi} it
      INNER JOIN ${DatabaseHelper.tableTransaksi} t ON it.id_transaksi = t.id
      WHERE DATE(t.tanggal) = DATE('now', 'localtime')
      GROUP BY it.nama_menu
      ORDER BY quantity DESC
    ''');
  }

  // Get sales by menu item in date range
  Future<List<Map<String, dynamic>>> getSalesByMenuItem(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        it.nama_menu,
        SUM(it.jumlah) as total_quantity,
        SUM(it.jumlah * it.harga) as total_revenue,
        AVG(it.harga) as average_price
      FROM ${DatabaseHelper.tableItemTransaksi} it
      INNER JOIN ${DatabaseHelper.tableTransaksi} t ON it.id_transaksi = t.id
      WHERE DATE(t.tanggal) BETWEEN ? AND ?
      GROUP BY it.nama_menu
      ORDER BY total_revenue DESC
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);
  }

  // Update item transaksi
  Future<int> update(ItemTransaksiModel item) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tableItemTransaksi,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete item transaksi
  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableItemTransaksi,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete items by transaksi ID
  Future<int> deleteByTransaksiId(int transaksiId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableItemTransaksi,
      where: 'id_transaksi = ?',
      whereArgs: [transaksiId],
    );
  }
}