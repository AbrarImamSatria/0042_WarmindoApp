import 'package:warmindo_app/data/model/menu_model.dart';
import 'database_helper.dart';

class MenuDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Insert menu baru
  Future<int> insert(MenuModel menu) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tableMenu,
      menu.toMapForInsert(),
    );
  }

  // Get menu by ID
  Future<MenuModel?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMenu,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return MenuModel.fromMap(maps.first);
  }

  // Get all menu
  Future<List<MenuModel>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMenu,
      orderBy: 'kategori ASC, nama ASC',
    );

    return List.generate(maps.length, (i) {
      return MenuModel.fromMap(maps[i]);
    });
  }

  // Get menu by kategori
  Future<List<MenuModel>> getByKategori(String kategori) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMenu,
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'nama ASC',
    );

    return List.generate(maps.length, (i) {
      return MenuModel.fromMap(maps[i]);
    });
  }

  // Search menu by nama
  Future<List<MenuModel>> searchByNama(String keyword) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMenu,
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'nama ASC',
    );

    return List.generate(maps.length, (i) {
      return MenuModel.fromMap(maps[i]);
    });
  }

  // Update menu
  Future<int> update(MenuModel menu) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tableMenu,
      menu.toMap(),
      where: 'id = ?',
      whereArgs: [menu.id],
    );
  }

  // Update foto menu
  Future<int> updateFoto(int id, String? fotoPath) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tableMenu,
      {'foto': fotoPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete menu
  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tableMenu,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if nama menu already exists
  Future<bool> isNamaExist(String nama, {int? excludeId}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableMenu,
      where: excludeId != null ? 'nama = ? AND id != ?' : 'nama = ?',
      whereArgs: excludeId != null ? [nama, excludeId] : [nama],
    );

    return maps.isNotEmpty;
  }

  // Get count by kategori (untuk statistik)
  Future<Map<String, int>> getCountByKategori() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT kategori, COUNT(*) as count 
      FROM ${DatabaseHelper.tableMenu} 
      GROUP BY kategori
    ''');

    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['kategori'] as String] = row['count'] as int;
    }
    return counts;
  }
}