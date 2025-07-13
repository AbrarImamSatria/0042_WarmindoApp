import 'package:flutter/material.dart';
import 'package:warmindo_app/bloc/backup/backup_bloc.dart';
import 'package:warmindo_app/presentation/pages/backup/widgets/backup_item_card.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';

class BackupListSection extends StatelessWidget {
  final BackupState state;
  final Function(String) onRestore;
  final Function(String) onShare;
  final Function(String) onDelete;

  const BackupListSection({
    Key? key,
    required this.state,
    required this.onRestore,
    required this.onShare,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state is BackupLoading) {
      return const LoadingWidget();
    }

    if (state is BackupLoaded) {
      // Cast state ke BackupLoaded untuk mengakses property backupHistory
      final backupLoadedState = state as BackupLoaded;
      return _buildBackupList(backupLoadedState.backupHistory);
    }

    return _buildEmptyState();
  }

  // Membangun daftar backup
  Widget _buildBackupList(List<Map<String, dynamic>> backupHistory) {
    if (backupHistory.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: backupHistory.length,
      itemBuilder: (context, index) {
        final backup = backupHistory[index];
        return BackupItemCard(
          fileName: backup['name'] ?? '',
          fileSize: backup['formattedSize'] ?? '',
          modifiedDate: backup['created'] ?? DateTime.now(),
          onRestore: () => onRestore(backup['path'] ?? ''),
          onShare: () => onShare(backup['path'] ?? ''),
          onDelete: () => onDelete(backup['path'] ?? ''),
        );
      },
    );
  }

  // Membangun empty state ketika belum ada backup
  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.backup_outlined,
      title: 'Belum Ada Backup',
      subtitle: 'Buat backup untuk mengamankan data Anda',
    );
  }
}