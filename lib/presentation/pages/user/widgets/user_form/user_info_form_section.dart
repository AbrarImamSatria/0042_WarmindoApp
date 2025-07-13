import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_form/role_selection_section.dart';
import 'package:warmindo_app/presentation/widgets/custom_text_field.dart';

class UserInfoFormSection extends StatelessWidget {
  final TextEditingController namaController;
  final String selectedRole;
  final bool isEditMode;
  final bool canEditRole;
  final Function(String) onRoleChanged;

  const UserInfoFormSection({
    Key? key,
    required this.namaController,
    required this.selectedRole,
    required this.isEditMode,
    required this.canEditRole,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Field nama pengguna
        _buildNameField(),
        
        // Pemilihan role (hanya untuk edit mode dan user adalah owner)
        if (isEditMode && canEditRole) ...[
          const SizedBox(height: 16),
          RoleSelectionSection(
            selectedRole: selectedRole,
            onRoleChanged: onRoleChanged,
          ),
        ],
      ],
    );
  }

  // Membangun field nama pengguna
  Widget _buildNameField() {
    return CustomTextField(
      label: 'Nama Pengguna',
      hint: 'Masukkan nama pengguna',
      controller: namaController,
      prefixIcon: const Icon(Icons.person_outline),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama tidak boleh kosong';
        }
        if (value.length < 3) {
          return 'Nama minimal 3 karakter';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }
}