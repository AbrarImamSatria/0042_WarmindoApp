import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    final strengthData = _getStrengthData(strength);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStrengthLabel(strengthData),
          const SizedBox(height: 8),
          _buildStrengthBar(strength, strengthData['color']),
        ],
      ),
    );
  }

  // Menghitung kekuatan password
  int _calculateStrength() {
    int strength = 0;
    
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    return strength;
  }

  // Mendapatkan data kekuatan password (warna dan teks)
  Map<String, dynamic> _getStrengthData(int strength) {
    if (strength <= 1) {
      return {
        'color': AppTheme.error,
        'text': 'Lemah',
      };
    } else if (strength <= 3) {
      return {
        'color': AppTheme.warning,
        'text': 'Sedang',
      };
    } else {
      return {
        'color': AppTheme.success,
        'text': 'Kuat',
      };
    }
  }

  // Membangun label kekuatan password
  Widget _buildStrengthLabel(Map<String, dynamic> strengthData) {
    return Row(
      children: [
        Text(
          'Kekuatan Password: ',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          strengthData['text'],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: strengthData['color'],
          ),
        ),
      ],
    );
  }

  // Membangun bar indikator kekuatan
  Widget _buildStrengthBar(int strength, Color strengthColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        children: [
          // Background bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Progress bar
          FractionallySizedBox(
            widthFactor: strength / 5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: strengthColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}