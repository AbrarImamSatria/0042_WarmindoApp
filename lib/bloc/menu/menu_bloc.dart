import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:warmindo_app/data/repository/menu_repository.dart';
import '../auth/auth_bloc.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _menuRepository = MenuRepository();
  final AuthBloc _authBloc;

  MenuBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(MenuInitial()) {
    on<MenuLoad>(_onMenuLoad);
    on<MenuLoadByCategory>(_onMenuLoadByCategory);
    on<MenuSearch>(_onMenuSearch);
    on<MenuAdd>(_onMenuAdd);
    on<MenuUpdate>(_onMenuUpdate);
    on<MenuUpdateFoto>(_onMenuUpdateFoto);
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