

import 'package:warmindo_app/data/datasource/pengguna_dao.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';

class PenggunaRepository {
  final PenggunaDao _penggunaDao = PenggunaDao();

  // Login
  Future<PenggunaModel?> login(String nama, String password) async {
    try {
      return await _penggunaDao.login(nama, password);
    } catch (e) {
      throw Exception('Gagal login: ${e.toString()}');
    }
  }

  // Register pengguna baru
  Future<int> register(PenggunaModel pengguna) async {
    try {
      // Check if nama already exists
      final isExist = await _penggunaDao.isNamaExist(pengguna.nama);
      if (isExist) {
        throw Exception('Nama pengguna sudah terdaftar');
      }

      return await _penggunaDao.insert(pengguna);
    } catch (e) {
      throw Exception('Gagal mendaftarkan pengguna: ${e.toString()}');
    }
  }

  // Get pengguna by ID
  Future<PenggunaModel?> getPenggunaById(int id) async {
    try {
      return await _penggunaDao.getById(id);
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: ${e.toString()}');
    }
  }

  // Get all pengguna
  Future<List<PenggunaModel>> getAllPengguna() async {
    try {
      return await _penggunaDao.getAll();
    } catch (e) {
      throw Exception('Gagal mengambil daftar pengguna: ${e.toString()}');
    }
  }

  // Get pengguna by role
  Future<List<PenggunaModel>> getPenggunaByRole(String role) async {
    try {
      return await _penggunaDao.getByRole(role);
    } catch (e) {
      throw Exception('Gagal mengambil pengguna berdasarkan role: ${e.toString()}');
    }
  }

  // Update profile pengguna
  Future<bool> updateProfile(PenggunaModel pengguna) async {
    try {
      // Check if nama already exists (exclude current user)
      final isExist = await _penggunaDao.isNamaExist(
        pengguna.nama,
        excludeId: pengguna.id,
      );
      if (isExist) {
        throw Exception('Nama pengguna sudah digunakan');
      }

      final result = await _penggunaDao.update(pengguna);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal update profile: ${e.toString()}');
    }
  }

  // Update alamat
  Future<bool> updateAlamat(int id, String alamat) async {
    try {
      final result = await _penggunaDao.updateAlamat(id, alamat);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal update alamat: ${e.toString()}');
    }
  }

  // Change password
  Future<bool> changePassword(int id, String passwordLama, String passwordBaru) async {
    try {
      // Verify old password first
      final pengguna = await _penggunaDao.getById(id);
      if (pengguna == null) {
        throw Exception('Pengguna tidak ditemukan');
      }

      if (pengguna.password != passwordLama) {
        throw Exception('Password lama tidak sesuai');
      }

      final result = await _penggunaDao.updatePassword(id, passwordBaru);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal mengubah password: ${e.toString()}');
    }
  }

  // Delete pengguna
  Future<bool> deletePengguna(int id) async {
    try {
      // Check if this is the last owner
      final pengguna = await _penggunaDao.getById(id);
      if (pengguna?.isOwner ?? false) {
        final owners = await _penggunaDao.getByRole('pemilik');
        if (owners.length <= 1) {
          throw Exception('Tidak dapat menghapus pemilik terakhir');
        }
      }

      final result = await _penggunaDao.delete(id);
      return result > 0;
    } catch (e) {
      throw Exception('Gagal menghapus pengguna: ${e.toString()}');
    }
  }
}