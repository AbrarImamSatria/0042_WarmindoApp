import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/data/repository/pengguna_repository.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PenggunaRepository _penggunaRepository = PenggunaRepository();
  PenggunaModel? _currentUser;

  // Getter untuk current user
  PenggunaModel? get currentUser => _currentUser;

  // Helper method to check if user is owner
  bool get isOwner => _currentUser?.isOwner ?? false;

  // Helper method to check if user is employee
  bool get isEmployee => _currentUser?.isEmployee ?? false;

  AuthBloc() : super(AuthInitial()) {
    on<AuthLogin>(_onLogin);
    on<AuthLogout>(_onLogout);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthUpdateProfile>(_onUpdateProfile);
    on<AuthUpdateAlamat>(_onUpdateAlamat);
    on<AuthChangePassword>(_onChangePassword);
  }

  // Handle login
  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _penggunaRepository.login(event.nama, event.password);
      
      if (user != null) {
        _currentUser = user;
        emit(AuthSuccess(user: user));
      } else {
        emit(AuthFailure(error: 'Nama atau password salah'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // Handle logout
  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    _currentUser = null;
    emit(AuthInitial());
  }

  // Check auth status
  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    if (_currentUser != null) {
      emit(AuthSuccess(user: _currentUser!));
    } else {
      emit(AuthInitial());
    }
  }

  // Update profile
  Future<void> _onUpdateProfile(AuthUpdateProfile event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _penggunaRepository.updateProfile(event.user);
      
      if (success) {
        _currentUser = event.user;
        emit(AuthSuccess(
          user: event.user,
          message: 'Profile berhasil diupdate',
        ));
      } else {
        emit(AuthFailure(error: 'Gagal update profile'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // Update alamat
  Future<void> _onUpdateAlamat(AuthUpdateAlamat event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _penggunaRepository.updateAlamat(event.userId, event.alamat);
      
      if (success && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(alamat: event.alamat);
        emit(AuthSuccess(
          user: _currentUser!,
          message: 'Alamat berhasil diupdate',
        ));
      } else {
        emit(AuthFailure(error: 'Gagal update alamat'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // Change password
  Future<void> _onChangePassword(AuthChangePassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _penggunaRepository.changePassword(
        event.userId,
        event.passwordLama,
        event.passwordBaru,
      );
      
      if (success) {
        emit(AuthSuccess(
          user: _currentUser!,
          message: 'Password berhasil diubah',
        ));
      } else {
        emit(AuthFailure(error: 'Gagal mengubah password'));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}