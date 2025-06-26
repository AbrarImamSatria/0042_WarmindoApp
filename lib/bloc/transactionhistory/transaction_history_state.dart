part of 'transaction_history_bloc.dart';

@immutable
sealed class TransactionHistoryState {}

// Initial state
final class TransactionHistoryInitial extends TransactionHistoryState {}

// Loading state
final class TransactionHistoryLoading extends TransactionHistoryState {}

// Success state
final class TransactionHistorySuccess extends TransactionHistoryState {
  final List<TransaksiModel> transactions;

  TransactionHistorySuccess({required this.transactions});
}

// Detail loaded state
final class TransactionHistoryDetailLoaded extends TransactionHistoryState {
  final TransaksiModel transaction;
  final List<ItemTransaksiModel> items;

  TransactionHistoryDetailLoaded({
    required this.transaction,
    required this.items,
  });
}

// Failure state
final class TransactionHistoryFailure extends TransactionHistoryState {
  final String error;

  TransactionHistoryFailure({required this.error});
}