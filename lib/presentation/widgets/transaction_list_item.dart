import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

class TransactionListItem extends StatelessWidget {
  final TransaksiModel transaction;
  final VoidCallback? onTap;
  final bool showDate;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    this.onTap,
    this.showDate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Transaction Code
                  Text(
                    transaction.transactionCode,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Payment Method Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: transaction.isCash 
                          ? AppTheme.cashColor.withOpacity(0.1) 
                          : AppTheme.qrisColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: transaction.isCash 
                            ? AppTheme.cashColor 
                            : AppTheme.qrisColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          transaction.isCash ? Icons.money : Icons.qr_code,
                          size: 16,
                          color: transaction.isCash 
                              ? AppTheme.cashColor 
                              : AppTheme.qrisColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.metodeBayar.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: transaction.isCash 
                                ? AppTheme.cashColor 
                                : AppTheme.qrisColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Amount
              Text(
                CurrencyFormatter.formatRupiah(transaction.totalBayar),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              
              if (showDate) ...[
                const SizedBox(height: 8),
                // Date and Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${transaction.formattedDate} • ${transaction.formattedTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}