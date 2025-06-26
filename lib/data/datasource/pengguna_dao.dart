import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'database_helper.dart';

class PenggunaDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Insert pengguna baru
  Future<int> insert(PenggunaModel pengguna) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.tablePengguna,
      pengguna.toMapForInsert(),
    );
  }

  // Get pengguna by ID
  Future<PenggunaModel?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tablePengguna,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return PenggunaModel.fromMap(maps.first);
  }

  // Get pengguna by nama dan password (untuk login)
  Future<PenggunaModel?> login(String nama, String password) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tablePengguna,
      where: 'nama = ? AND password = ?',
      whereArgs: [nama, password],
    );

    if (maps.isEmpty) return null;
    return PenggunaModel.fromMap(maps.first);
  }

  // Get all pengguna
  Future<List<PenggunaModel>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tablePengguna,
      orderBy: 'nama ASC',
    );

    return List.generate(maps.length, (i) {
      return PenggunaModel.fromMap(maps[i]);
    });
  }

  // Get pengguna by role
  Future<List<PenggunaModel>> getByRole(String role) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tablePengguna,
      where: 'role = ?',
      whereArgs: [role],
      orderBy: 'nama ASC',
    );

    return List.generate(maps.length, (i) {
      return PenggunaModel.fromMap(maps[i]);
    });
  }

  // Update pengguna
  Future<int> update(PenggunaModel pengguna) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tablePengguna,
      pengguna.toMap(),
      where: 'id = ?',
      whereArgs: [pengguna.id],
    );
  }

  // Update alamat pengguna
  Future<int> updateAlamat(int id, String alamat) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tablePengguna,
      {'alamat': alamat},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update password
  Future<int> updatePassword(int id, String passwordBaru) async {
    final db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.tablePengguna,
      {'password': passwordBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete pengguna
  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.tablePengguna,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if nama already exists (untuk validasi)
  Future<bool> isNamaExist(String nama, {int? excludeId}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tablePengguna,
      where: excludeId != null ? 'nama = ? AND id != ?' : 'nama = ?',
      whereArgs: excludeId != null ? [nama, excludeId] : [nama],
    );

    return maps.isNotEmpty;
  }
}