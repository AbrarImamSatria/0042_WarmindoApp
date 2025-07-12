import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class TransactionActionButtons extends StatelessWidget {
  final int transactionId;
  final bool fromCart;
  final VoidCallback onPrintReceipt;
  final VoidCallback onGeneratePDF;
  final VoidCallback onNavigateBack;

  const TransactionActionButtons({
    Key? key,
    required this.transactionId,
    required this.fromCart,
    required this.onPrintReceipt,
    required this.onGeneratePDF,
    required this.onNavigateBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tombol print dan PDF
        _buildPrintAndPdfButtons(),
        const SizedBox(height: 16),
        
        // Tombol navigasi back/selesai
        _buildNavigationButton(),
      ],
    );
  }

  // Membangun tombol print dan PDF
  Widget _buildPrintAndPdfButtons() {
    return Row(
      children: [
        // Tombol print receipt
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Print Nota'),
            onPressed: onPrintReceipt,
          ),
        ),
        const SizedBox(width: 12),
        
        // Tombol generate PDF
        Expanded(
          child: PrimaryButton.icon(
            text: 'Simpan PDF',
            icon: Icons.save_alt,
            onPressed: onGeneratePDF,
          ),
        ),
      ],
    );
  }

  // Membangun tombol navigasi berdasarkan source
  Widget _buildNavigationButton() {
    return SizedBox(
      width: double.infinity,
      child: fromCart 
          ? PrimaryButton(
              text: 'Selesai',
              onPressed: onNavigateBack,
            )
          : PrimaryButton(
              text: 'Kembali',
              onPressed: onNavigateBack,
            ),
    );
  }
}