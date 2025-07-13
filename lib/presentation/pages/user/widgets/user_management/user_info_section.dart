import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.white),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppTheme.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kelola karyawan dengan menu titik tiga di setiap kartu',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}