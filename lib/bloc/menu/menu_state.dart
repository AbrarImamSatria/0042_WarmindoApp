part of 'menu_bloc.dart';

@immutable
sealed class MenuState {}

// Initial state
final class MenuInitial extends MenuState {}

// Loading state
final class MenuLoading extends MenuState {}

// Success state
final class MenuSuccess extends MenuState {
  final List<MenuModel> menus;
  final String? message;

  MenuSuccess({
    required this.menus,
    this.message,
  });
}

// Image picked state
final class MenuImagePicked extends MenuState {
  final String imagePath;
  final int? menuId;

  MenuImagePicked({
    required this.imagePath,
    this.menuId,
  });
}

// Failure state
final class MenuFailure extends MenuState {
  final String error;

  MenuFailure({required this.error});
}