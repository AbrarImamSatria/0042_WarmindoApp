import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/data/repository/pengguna_repository.dart';
import '../auth/auth_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final PenggunaRepository _penggunaRepository = PenggunaRepository();
  final AuthBloc _authBloc;

  ProfileBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(ProfileInitial()) {
    on<ProfileLoad>(_onLoad);
    on<ProfileGetCurrentLocation>(_onGetCurrentLocation);
    on<ProfileUpdateLocation>(_onUpdateLocation);
    on<ProfileUpdateAlamat>(_onUpdateAlamat);
  }

  // Load profile
  Future<void> _onLoad(ProfileLoad event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = _authBloc.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  // Get current location
  Future<void> _onGetCurrentLocation(ProfileGetCurrentLocation event, Emitter<ProfileState> emit) async {
    emit(ProfileLocationLoading());
    try {
      // Check permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Lokasi tidak diketahui';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
      }

      emit(ProfileLocationLoaded(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      ));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  // Update location from map selection
  Future<void> _onUpdateLocation(ProfileUpdateLocation event, Emitter<ProfileState> emit) async {
    emit(ProfileLocationLoading());
    try {
      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        event.latitude,
        event.longitude,
      );

      String address = 'Lokasi tidak diketahui';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
      }

      emit(ProfileLocationLoaded(
        latitude: event.latitude,
        longitude: event.longitude,
        address: address,
      ));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  // Update alamat with coordinates
  Future<void> _onUpdateAlamat(ProfileUpdateAlamat event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = _authBloc.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Format address with coordinates
      final fullAddress = '${event.address}|${event.latitude},${event.longitude}';
      
      // Update alamat
      await _penggunaRepository.updateAlamat(user.id!, fullAddress);
      
      // Update auth bloc
      _authBloc.add(AuthUpdateAlamat(
        userId: user.id!,
        alamat: fullAddress,
      ));

      emit(ProfileUpdateSuccess(
        message: 'Alamat berhasil diupdate',
      ));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }
}