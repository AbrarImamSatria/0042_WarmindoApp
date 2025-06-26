import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/data/repository/pengguna_repository.dart';
import '../auth/auth_bloc.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final PenggunaRepository _penggunaRepository = PenggunaRepository();
  final AuthBloc _authBloc;

  UserManagementBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(UserManagementInitial()) {
    on<UserManagementLoad>(_onLoad);
    on<UserManagementAdd>(_onAdd);
    on<UserManagementUpdate>(_onUpdate);
    on<UserManagementDelete>(_onDelete);
    on<UserManagementResetPassword>(_onResetPassword);
  }

  // Check owner permission
  bool _checkOwnerPermission() {
    return _authBloc.isOwner;
  }

  // Load all users
  Future<void> _onLoad(UserManagementLoad event, Emitter<UserManagementState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(UserManagementFailure(error: 'Hanya pemilik yang dapat mengelola pengguna'));
      return;
    }

    emit(UserManagementLoading());
    try {
      final users = await _penggunaRepository.getAllPengguna();
      emit(UserManagementSuccess(users: users));
    } catch (e) {
      emit(UserManagementFailure(error: e.toString()));
    }
  }

  // Add new user (employee)
  Future<void> _onAdd(UserManagementAdd event, Emitter<UserManagementState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(UserManagementFailure(error: 'Hanya pemilik yang dapat menambah pengguna'));
      return;
    }

    emit(UserManagementLoading());
    try {
      // Create employee user
      final newUser = PenggunaModel(
        nama: event.nama,
        password: event.password,
        role: 'karyawan', // Always create as employee
        alamat: null,
      );

      await _penggunaRepository.register(newUser);

      // Reload users
      final users = await _penggunaRepository.getAllPengguna();
      emit(UserManagementSuccess(
        users: users,
        message: 'Karyawan berhasil ditambahkan',
      ));
    } catch (e) {
      emit(UserManagementFailure(error: e.toString()));
    }
  }

  // Update user
  Future<void> _onUpdate(UserManagementUpdate event, Emitter<UserManagementState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(UserManagementFailure(error: 'Hanya pemilik yang dapat mengubah data pengguna'));
      return;
    }

    emit(UserManagementLoading());
    try {
      await _penggunaRepository.updateProfile(event.user);

      // Reload users
      final users = await _penggunaRepository.getAllPengguna();
      emit(UserManagementSuccess(
        users: users,
        message: 'Data pengguna berhasil diupdate',
      ));
    } catch (e) {
      emit(UserManagementFailure(error: e.toString()));
    }
  }

  // Delete user
  Future<void> _onDelete(UserManagementDelete event, Emitter<UserManagementState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(UserManagementFailure(error: 'Hanya pemilik yang dapat menghapus pengguna'));
      return;
    }

    // Prevent deleting self
    if (_authBloc.currentUser?.id == event.userId) {
      emit(UserManagementFailure(error: 'Tidak dapat menghapus akun sendiri'));
      return;
    }

    emit(UserManagementLoading());
    try {
      await _penggunaRepository.deletePengguna(event.userId);

      // Reload users
      final users = await _penggunaRepository.getAllPengguna();
      emit(UserManagementSuccess(
        users: users,
        message: 'Pengguna berhasil dihapus',
      ));
    } catch (e) {
      emit(UserManagementFailure(error: e.toString()));
    }
  }

  // Reset password (to default)
  Future<void> _onResetPassword(UserManagementResetPassword event, Emitter<UserManagementState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(UserManagementFailure(error: 'Hanya pemilik yang dapat reset password'));
      return;
    }

    emit(UserManagementLoading());
    try {
      // Get user first to verify
      final user = await _penggunaRepository.getPenggunaById(event.userId);
      if (user == null) {
        throw Exception('Pengguna tidak ditemukan');
      }

      // Reset to default password
      await _penggunaRepository.changePassword(
        event.userId, 
        user.password, // Current password
        '123456', // Default password
      );

      // Reload users
      final users = await _penggunaRepository.getAllPengguna();
      emit(UserManagementSuccess(
        users: users,
        message: 'Password berhasil direset ke default (123456)',
      ));
    } catch (e) {
      emit(UserManagementFailure(error: e.toString()));
    }
  }
}