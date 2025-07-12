import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/print/print_bloc.dart';
import 'package:warmindo_app/bloc/transactionhistory/transaction_history_bloc.dart';
import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/presentation/pages/transaction/widgets/transaction_detail/order_items_section.dart';
import 'package:warmindo_app/presentation/pages/transaction/widgets/transaction_detail/transaction_action_buttons.dart';
import 'package:warmindo_app/presentation/pages/transaction/widgets/transaction_detail/transaction_info_card.dart';
import 'package:warmindo_app/presentation/pages/transaction/widgets/transaction_detail/transaction_success_header.dart';
import 'package:warmindo_app/presentation/utils/permission_service.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;
  final bool fromCart;

  const TransactionDetailPage({
    Key? key, 
    required this.transactionId,
    this.fromCart = false,
  }) : super(key: key);

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  void initState() {
    super.initState();
    // Memuat detail transaksi
    context.read<TransactionHistoryBloc>().add(
      TransactionHistoryLoadDetail(transactionId: widget.transactionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Membangun AppBar dengan conditional back button dan menu
  PreferredSizeWidget _buildAppBar() {
    final authState = context.read<AuthBloc>().state;
    final isOwner = authState is AuthSuccess && authState.user.isOwner;

    return AppBar(
      // Sembunyikan back button jika dari cart
      automaticallyImplyLeading: !widget.fromCart,
      title: const Text('Detail Transaksi'),
      actions: [
        if (isOwner) _buildPopupMenu(),
      ],
    );
  }

  // Membangun popup menu untuk owner
  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuAction,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Transaksi'),
            ],
          ),
        ),
      ],
    );
  }

  // Menangani aksi menu popup
  Future<void> _handleMenuAction(String value) async {
    if (value == 'delete') {
      await _handleDeleteTransaction();
    }
  }

  // Menangani penghapusan transaksi
  Future<void> _handleDeleteTransaction() async {
    final confirm = await CustomDialog.showDeleteConfirm(
      context: context,
      itemName: 'transaksi',
    );
    
    if (confirm) {
      context.read<TransactionHistoryBloc>().add(
        TransactionHistoryDelete(transactionId: widget.transactionId),
      );
      
      // Navigasi setelah delete
      if (widget.fromCart) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      } else {
        Navigator.pop(context, true); // Kirim signal refresh
      }
    }
  }

  // Membangun body dengan WillPopScope untuk handle back button
  Widget _buildBody() {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: SafeArea(
        child: BlocListener<PrintBloc, PrintState>(
          listener: _handlePrintBlocListener,
          child: BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
            builder: _buildTransactionContent,
          ),
        ),
      ),
    );
  }

  // Menangani back press untuk navigation yang tepat
  Future<bool> _handleBackPress() async {
    if (widget.fromCart) {
      // Jika dari cart, redirect ke main page
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
      return false;
    }
    return true; // Allow normal back untuk transaction history
  }

  // Menangani listener untuk PrintBloc
  void _handlePrintBlocListener(BuildContext context, PrintState state) {
    if (state is PrintLoading) {
      CustomDialog.showLoading(
        context: context,
        message: 'Memproses...',
      );
    } else if (state is PrintSuccess) {
      CustomDialog.hideLoading(context);
      CustomDialog.showSuccess(
        context: context,
        message: state.message,
      );
    } else if (state is PrintPDFGenerated) {
      _handlePDFGenerated(state);
    } else if (state is PrintFailure) {
      CustomDialog.hideLoading(context);
      CustomDialog.showError(context: context, message: state.error);
    }
  }

  // Menangani PDF yang berhasil dibuat
  void _handlePDFGenerated(PrintPDFGenerated state) {
    CustomDialog.hideLoading(context);
    CustomDialog.showSuccess(
      context: context,
      message: state.message,
      onPressed: () {
        // Share PDF file
        Share.shareXFiles([XFile(state.filePath)]);
      },
    );
  }

  // Membangun konten transaksi berdasarkan state
  Widget _buildTransactionContent(BuildContext context, TransactionHistoryState state) {
    if (state is TransactionHistoryLoading) {
      return const LoadingWidget();
    } else if (state is TransactionHistoryDetailLoaded) {
      return _buildTransactionDetail(state.transaction, state.items);
    } else if (state is TransactionHistoryFailure) {
      return _buildErrorContent(state.error);
    }
    return const SizedBox();
  }

  // Membangun detail transaksi lengkap
  Widget _buildTransactionDetail(
    TransaksiModel transaction,
    List<ItemTransaksiModel> items,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header sukses transaksi
          TransactionSuccessHeader(transaction: transaction),

          // Konten detail transaksi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informasi pembayaran
                TransactionInfoCard(transaction: transaction),
                const SizedBox(height: 16),

                // Detail pesanan
                OrderItemsSection(
                  items: items,
                  totalAmount: transaction.totalBayar,
                ),
                const SizedBox(height: 24),

                // Tombol aksi
                TransactionActionButtons(
                  transactionId: widget.transactionId,
                  fromCart: widget.fromCart,
                  onPrintReceipt: _handlePrintReceipt,
                  onGeneratePDF: _handleGeneratePDF,
                  onNavigateBack: _handleNavigateBack,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Membangun konten error
  Widget _buildErrorContent(String error) {
    return Center(
      child: Text(
        error,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  // Menangani print receipt
  void _handlePrintReceipt() {
    context.read<PrintBloc>().add(
      PrintReceipt(transactionId: widget.transactionId),
    );
  }

  // Menangani generate PDF dengan permission check
  Future<void> _handleGeneratePDF() async {
    bool hasPermission = await PermissionService.requestStorage(context);
    
    if (hasPermission) {
      context.read<PrintBloc>().add(
        PrintGeneratePDF(transactionId: widget.transactionId),
      );
    }
  }

  // Menangani navigasi kembali
  void _handleNavigateBack() {
    if (widget.fromCart) {
      // Navigate to home page dan clear semua route sebelumnya
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }
}