part of 'transaction_history_bloc.dart';

@immutable
sealed class TransactionHistoryEvent {}

// Load all transactions (filtered by role)
final class TransactionHistoryLoad extends TransactionHistoryEvent {}

// Load by date range
final class TransactionHistoryLoadByDate extends TransactionHistoryEvent {
  final DateTime startDate;
  final DateTime endDate;

  TransactionHistoryLoadByDate({
    required this.startDate,
    required this.endDate,
  });
}

// Load transaction detail
final class TransactionHistoryLoadDetail extends TransactionHistoryEvent {
  final int transactionId;

  TransactionHistoryLoadDetail({required this.transactionId});
}

// Delete transaction
final class TransactionHistoryDelete extends TransactionHistoryEvent {
  final int transactionId;

  TransactionHistoryDelete({required this.transactionId});
}