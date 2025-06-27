part of 'print_bloc.dart';

@immutable
sealed class PrintState {}

// Initial state
final class PrintInitial extends PrintState {}

// Loading state
final class PrintLoading extends PrintState {}

// Success state
final class PrintSuccess extends PrintState {
  final String message;

  PrintSuccess({required this.message});
}

// PDF generated state
final class PrintPDFGenerated extends PrintState {
  final String filePath;
  final String message;

  PrintPDFGenerated({
    required this.filePath,
    required this.message,
  });
}

// Failure state
final class PrintFailure extends PrintState {
  final String error;

  PrintFailure({required this.error});
}