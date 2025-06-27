part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {}

// Load all menu
final class MenuLoad extends MenuEvent {}

// Load menu by category
final class MenuLoadByCategory extends MenuEvent {
  final String kategori;

  MenuLoadByCategory({required this.kategori});
}

// Search menu
final class MenuSearch extends MenuEvent {
  final String keyword;

  MenuSearch({required this.keyword});
}

// Add menu
final class MenuAdd extends MenuEvent {
  final MenuModel menu;

  MenuAdd({required this.menu});
}

// Update menu
final class MenuUpdate extends MenuEvent {
  final MenuModel menu;

  MenuUpdate({required this.menu});
}

// Update foto menu
final class MenuUpdateFoto extends MenuEvent {
  final int menuId;
  final String? fotoPath;

  MenuUpdateFoto({
    required this.menuId,
    required this.fotoPath,
  });
}
// Pick image from camera
final class MenuPickImageFromCamera extends MenuEvent {
  final int? menuId; // null if for new menu

  MenuPickImageFromCamera({this.menuId});
}

// Pick image from gallery
final class MenuPickImageFromGallery extends MenuEvent {
  final int? menuId; // null if for new menu

  MenuPickImageFromGallery({this.menuId});
}

// Delete menu
final class MenuDelete extends MenuEvent {
  final int menuId;

  MenuDelete({required this.menuId});
}