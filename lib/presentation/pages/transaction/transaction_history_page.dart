import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/transactionhistory/transaction_history_bloc.dart';
import 'package:warmindo_app/presentation/pages/transaction/widgets/transaction_history/date_filter_section.dart';
import 'package:warmindo_app/presentation/pages/transaction/widgets/transaction_history/transaction_list_section.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> 
    with AutomaticKeepAliveClientMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  bool get wantKeepAlive => true; // Jangan destroy state
  
  @override
  void initState() {
    super.initState();
    // Memuat transaksi saat halaman dibuka
    _loadTransactions();
  }

  // Memuat transaksi berdasarkan filter atau semua
  void _loadTransactions() {
    if (_startDate != null && _endDate != null) {
      context.read<TransactionHistoryBloc>().add(
        TransactionHistoryLoadByDate(
          startDate: _startDate!,
          endDate: _endDate!,
        ),
      );
    } else {
      context.read<TransactionHistoryBloc>().add(TransactionHistoryLoad());
    }
  }

  // Menampilkan date range picker dengan tema yang disesuaikan
  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryRed,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      
      // Load transaksi dengan filter tanggal
      context.read<TransactionHistoryBloc>().add(
        TransactionHistoryLoadByDate(
          startDate: picked.start,
          endDate: picked.end,
        ),
      );
    }
  }

  // Membersihkan filter tanggal
  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    context.read<TransactionHistoryBloc>().add(TransactionHistoryLoad());
  }

  // Menangani tap pada item transaksi
  Future<void> _handleTransactionTap(int transactionId) async {
    await Navigator.pushNamed(
      context,
      AppRouter.transactionDetail,
      arguments: transactionId,
    );
    
    // Refresh setelah kembali dari detail
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      _loadTransactions();
    }
  }

  // Format tanggal untuk ditampilkan
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Penting untuk AutomaticKeepAliveClientMixin
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Membangun AppBar dengan tombol filter untuk owner
  PreferredSizeWidget _buildAppBar() {
    final authState = context.read<AuthBloc>().state;
    final isOwner = authState is AuthSuccess && authState.user.isOwner;
    
    return AppBar(
      title: const Text('Riwayat Transaksi'),
      actions: [
        if (isOwner)
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showDateRangePicker,
          ),
      ],
    );
  }

  // Membangun body dengan filter dan list transaksi
  Widget _buildBody() {
    return Column(
      children: [
        // Section filter tanggal (jika aktif)
        if (_startDate != null && _endDate != null)
          DateFilterSection(
            startDate: _startDate!,
            endDate: _endDate!,
            onClearFilter: _clearFilter,
            formatDate: _formatDate,
          ),
        
        // Section list transaksi
        Expanded(
          child: TransactionListSection(
            onTransactionTap: _handleTransactionTap,
            onRefresh: _loadTransactions,
          ),
        ),
      ],
    );
  }
}