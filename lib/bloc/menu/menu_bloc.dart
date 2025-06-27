import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/data/repository/menu_repository.dart';
import 'dart:io';
import '../auth/auth_bloc.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _menuRepository = MenuRepository();
  final AuthBloc _authBloc;
  final ImagePicker _imagePicker = ImagePicker();

  MenuBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(MenuInitial()) {
    on<MenuLoad>(_onMenuLoad);
    on<MenuLoadByCategory>(_onMenuLoadByCategory);
    on<MenuSearch>(_onMenuSearch);
    on<MenuAdd>(_onMenuAdd);
    on<MenuUpdate>(_onMenuUpdate);
    on<MenuUpdateFoto>(_onMenuUpdateFoto);
    on<MenuPickImageFromCamera>(_onPickImageFromCamera);
    on<MenuPickImageFromGallery>(_onPickImageFromGallery);
    on<MenuDelete>(_onMenuDelete);
  }

  // Check if user is owner (for permission)
  bool _checkOwnerPermission() {
    return _authBloc.isOwner;
  }

  // Load all menu
  Future<void> _onMenuLoad(MenuLoad event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final menus = await _menuRepository.getAllMenu();
      emit(MenuSuccess(menus: menus));
    } catch (e) {
      emit(MenuFailure(error: e.toString()));
    }
  }

  // Load menu by category
  Future<void> _onMenuLoadByCategory(MenuLoadByCategory event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final menus = await _menuRepository.getMenuByKategori(event.kategori);
      emit(MenuSuccess(menus: menus));
    } catch (e) {
      emit(MenuFailure(error: e.toString()));
    }
  }

  // Search menu
  Future<void> _onMenuSearch(MenuSearch event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final menus = await _menuRepository.searchMenu(event.keyword);
      emit(MenuSuccess(menus: menus));
    } catch (e) {
      emit(MenuFailure(error: e.toString()));
    }
  }

  // Add menu (Owner only)
  Future<void> _onMenuAdd(MenuAdd event, Emitter<MenuState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(MenuFailure(error: 'Hanya pemilik yang dapat menambah menu'));
      return;
    }

    emit(MenuLoading());
    try {
      await _menuRepository.createMenu(event.menu);
      
      // Reload menu list
      final menus = await _menuRepository.getAllMenu();
      emit(MenuSuccess(
        menus: menus,
        message: 'Menu berhasil ditambahkan',
      ));
    } catch (e) {
      emit(MenuFailure(error: e.toString()));
    }
  }

  // Update menu (Owner only)
  Future<void> _onMenuUpdate(MenuUpdate event, Emitter<MenuState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(MenuFailure(error: 'Hanya pemilik yang dapat mengubah menu'));
      return;
    }

    emit(MenuLoading());
    try {
      await _menuRepository.updateMenu(event.menu);
      
      // Reload menu list
      final menus = await _menuRepository.getAllMenu();
      emit(MenuSuccess(
        menus: menus,
        message: 'Menu berhasil diupdate',
      ));
    } catch (e) {
      emit(MenuFailure(error: e.toString()));
    }
  }

  // Update foto menu (Owner only)
  Future<void> _onMenuUpdateFoto(MenuUpdateFoto event, Emitter<MenuState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(MenuFailure(error: 'Hanya pemilik yang dapat mengubah foto menu'));
      return;
    }

    emit(MenuLoading());
    try {
      await _menuRepository.updateFotoMenu(event.menuId, event.fotoPath);
      
      // Reload menu list
      final menus = await _menuRepository.getAllMenu();
      emit(MenuSuccess(
        menus: menus,
        message: 'Foto menu berhasil diupdate',
      ));
    } catch (e) {
      emit(MenuFailure(error: e.toString()));
    }
  }

  // Pick image from camera
  Future<void> _onPickImageFromCamera(MenuPickImageFromCamera event, Emitter<MenuState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(MenuFailure(error: 'Hanya pemilik yang dapat mengambil foto'));
      return;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (photo != null) {
        // Save to app directory
        final savedPath = await _saveImageToAppDirectory(photo);
        
        emit(MenuImagePicked(
          imagePath: savedPath,
          menuId: event.menuId,
        ));

        // If menuId is provided, update the menu photo
        if (event.menuId != null) {
          await _menuRepository.updateFotoMenu(event.menuId!, savedPath);
          
          // Reload menu list
          final menus = await _menuRepository.getAllMenu();
          emit(MenuSuccess(
            menus: menus,
            message: 'Foto berhasil diambil dari kamera',
          ));
        }
      }
    } catch (e) {
      emit(MenuFailure(error: 'Gagal mengambil foto: ${e.toString()}'));
    }
  }

  // Pick image from gallery
  Future<void> _onPickImageFromGallery(MenuPickImageFromGallery event, Emitter<MenuState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(MenuFailure(error: 'Hanya pemilik yang dapat memilih foto'));
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Save to app directory
        final savedPath = await _saveImageToAppDirectory(image);
        
        emit(MenuImagePicked(
          imagePath: savedPath,
          menuId: event.menuId,
        ));

        // If menuId is provided, update the menu photo
        if (event.menuId != null) {
          await _menuRepository.updateFotoMenu(event.menuId!, savedPath);
          
          // Reload menu list
          final menus = await _menuRepository.getAllMenu();
          emit(MenuSuccess(
            menus: menus,
            message: 'Foto berhasil dipilih dari galeri',
          ));
        }
      }
    } catch (e) {
      emit(MenuFailure(error: 'Gagal memilih foto: ${e.toString()}'));
    }
  }

  // Save image to app directory
  Future<String> _saveImageToAppDirectory(XFile imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final menuImagesDir = Directory('${directory.path}/menu_images');
    
    if (!await menuImagesDir.exists()) {
      await menuImagesDir.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
    final savedImage = File('${menuImagesDir.path}/$fileName');
    
    await File(imageFile.path).copy(savedImage.path);
    
    return savedImage.path;
  }

  // Delete menu (Owner only)
  Future<void> _onMenuDelete(MenuDelete event, Emitter<MenuState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(MenuFailure(error: 'Hanya pemilik yang dapat menghapus menu'));
      return;
    }

    emit(MenuLoading());
    try {
      await _menuRepository.deleteMenu(event.menuId);
      
      // Reload menu list
      final menus = await _menuRepository.getAllMenu();
      emit(MenuSuccess(
        menus: menus,
        message: 'Menu berhasil dihapus',
      ));
    } catch (e) {
      emit(MenuFailure(error: e.toString()));
    }
  }
}