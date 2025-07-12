import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/transactionhistory/transaction_history_bloc.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';
import 'package:warmindo_app/presentation/widgets/transaction_list_item.dart';

class TransactionListSection extends StatelessWidget {
  final Function(int) onTransactionTap;
  final VoidCallback onRefresh;

  const TransactionListSection({
    Key? key,
    required this.onTransactionTap,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
      builder: (context, state) {
        return _buildContentByState(state);
      },
    );
  }

  // Membangun konten berdasarkan state
  Widget _buildContentByState(TransactionHistoryState state) {
    if (state is TransactionHistoryLoading) {
      return const LoadingWidget();
    } else if (state is TransactionHistorySuccess) {
      return _buildTransactionList(state);
    } else if (state is TransactionHistoryFailure) {
      return _buildErrorState(state.error);
    }
    return const SizedBox();
  }

  // Membangun daftar transaksi atau empty state
  Widget _buildTransactionList(TransactionHistorySuccess state) {
    if (state.transactions.isEmpty) {
      return EmptyStateWidget.noTransaction();
    }
    
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        key: const PageStorageKey('transaction_list'), // Maintain scroll position
        padding: const EdgeInsets.all(16.0),
        itemCount: state.transactions.length,
        itemBuilder: (context, index) {
          final transaction = state.transactions[index];
          
          return TransactionListItem(
            transaction: transaction,
            onTap: () => onTransactionTap(transaction.id!),
          );
        },
      ),
    );
  }

  // Membangun error state
  Widget _buildErrorState(String error) {
    return EmptyStateWidget.error(
      message: error,
      onRetry: onRefresh,
    );
  }

  // Menangani refresh dengan delay untuk memastikan selesai
  Future<void> _handleRefresh() async {
    onRefresh();
    await Future.delayed(const Duration(milliseconds: 300));
  }
}