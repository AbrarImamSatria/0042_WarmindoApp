import 'package:warmindo_app/data/datasource/menu_dao.dart';
import 'package:warmindo_app/data/model/menu_model.dart';

class MenuRepository {
  final MenuDao _menuDao = MenuDao();

  // Create menu
  Future<int> createMenu(MenuModel menu) async {
    try {
      // Check if nama already exists
      final isExist = await _menuDao.isNamaExist(menu.nama);
      if (isExist) {
        throw Exception('Menu dengan nama tersebut sudah ada');
      }

      return await _menuDao.insert(menu);
    } catch (e) {
      throw Exception('Gagal menambahkan menu: ${e.toString()}');
    }
  }

  // Get menu by ID
  Future<MenuModel?> getMenuById(int id) async {
    try {
      return await _menuDao.getById(id);
    } catch (e) {
      throw Exception('Gagal mengambil data menu: ${e.toString()}');
    }
  }

  // Get all menu
  Future<List<MenuModel>> getAllMenu() async {
    try {
      return await _menuDao.getAll();
    } catch (e) {
      throw Exception('Gagal mengambil daftar menu: ${e.toString()}');
    }
  }

  // Get menu by kategori
  Future<List<MenuModel>> getMenuByKategori(String kategori) async {
    try {
      return await _menuDao.getByKategori(kategori);
    } catch (e) {
      throw Exception('Gagal mengambil menu berdasarkan kategori: ${e.toString()}');
    }
  }

  // Search menu
  Future<List<MenuModel>> searchMenu(String keyword) async {
    try {
      if (keyword.isEmpty) {
        return await _menuDao.getAll();
      }
      return await _menuDao.searchByNama(keyword);
    } catch (e) {
      throw Exception('Gagal mencari menu: ${e.toString()}');
    }
  }

  // Update menu
  Future<bool> updateMenu(MenuModel menu) async {
    try {
      // Check if nama already exists (exclude current menu)
      final isExist = await _menuDao.isNamaExist(
        menu.nama,
        excludeId: menu.id,
      );
      if (isExist) {
        throw Exception('Menu dengan nama tersebut sudah ada');
      }

      final result = await _menuDao.update(menu);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal update menu: ${e.toString()}');
    }
  }

  // Update foto menu
  Future<bool> updateFotoMenu(int id, String? fotoPath) async {
    try {
      final result = await _menuDao.updateFoto(id, fotoPath);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal update foto menu: ${e.toString()}');
    }
  }

  // Delete menu
  Future<bool> deleteMenu(int id) async {
    try {
      final result = await _menuDao.delete(id);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal menghapus menu: ${e.toString()}');
    }
  }

  // Get menu statistics
  Future<Map<String, int>> getMenuStatistics() async {
    try {
      return await _menuDao.getCountByKategori();
    } catch (e) {
      throw Exception('Gagal mengambil statistik menu: ${e.toString()}');
    }
  }

  // Get menu for POS (grouped by category)
  Future<Map<String, List<MenuModel>>> getMenuGroupedByCategory() async {
    try {
      final allMenu = await _menuDao.getAll();
      final Map<String, List<MenuModel>> grouped = {};

      for (final menu in allMenu) {
        if (!grouped.containsKey(menu.kategori)) {
          grouped[menu.kategori] = [];
        }
        grouped[menu.kategori]!.add(menu);
      }

      return grouped;
    } catch (e) {
      throw Exception('Gagal mengambil menu untuk POS: ${e.toString()}');
    }
  }
}