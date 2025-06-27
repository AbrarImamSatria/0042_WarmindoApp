part of 'print_bloc.dart';

@immutable
sealed class PrintEvent {}

// Print receipt/nota
final class PrintReceipt extends PrintEvent {
  final int transactionId;

  PrintReceipt({required this.transactionId});
}

// Print daily report
final class PrintDailyReport extends PrintEvent {
  final DateTime date;

  PrintDailyReport({required this.date});
}

// Generate PDF without printing
final class PrintGeneratePDF extends PrintEvent {
  final int transactionId;

  PrintGeneratePDF({required this.transactionId});
}