import 'package:flutter/material.dart';

class ShareBackupDialog extends StatelessWidget {
  final VoidCallback onShare;

  const ShareBackupDialog({
    Key? key,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Backup Berhasil'),
      content: const Text('Apakah Anda ingin membagikan file backup?'),
      actions: [
        _buildCancelButton(context),
        _buildShareButton(),
      ],
    );
  }

  // Membangun tombol batal
  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Tidak'),
    );
  }

  // Membangun tombol bagikan
  Widget _buildShareButton() {
    return ElevatedButton(
      onPressed: onShare,
      child: const Text('Bagikan'),
    );
  }
}