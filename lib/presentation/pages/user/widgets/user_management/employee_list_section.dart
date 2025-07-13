import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_management/user_card.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';

class EmployeeListSection extends StatelessWidget {
  final List<PenggunaModel> filteredEmployees;
  final String searchQuery;
  final VoidCallback onRefresh;
  final Function(int) onEditUser;
  final Function(PenggunaModel) onEditPassword;
  final Function(PenggunaModel) onDeleteUser;
  final Function(PenggunaModel) onResetPassword;

  const EmployeeListSection({
    Key? key,
    required this.filteredEmployees,
    required this.searchQuery,
    required this.onRefresh,
    required this.onEditUser,
    required this.onEditPassword,
    required this.onDeleteUser,
    required this.onResetPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filteredEmployees.isEmpty) {
      return _buildEmptyState();
    }

    return _buildEmployeeList(context);
  }

  // Membangun empty state berdasarkan kondisi
  Widget _buildEmptyState() {
    if (searchQuery.isNotEmpty) {
      return EmptyStateWidget.searchNotFound(query: searchQuery);
    } else {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'Belum Ada Karyawan',
        subtitle: 'Tambahkan karyawan untuk mulai',
      );
    }
  }

  // Membangun daftar karyawan
  Widget _buildEmployeeList(BuildContext context) {
    final currentUser = context.read<AuthBloc>().currentUser;
    
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredEmployees.length,
        itemBuilder: (context, index) {
          final user = filteredEmployees[index];
          final isCurrentUser = currentUser?.id == user.id;
          
          return UserCard(
            user: user,
            isCurrentUser: isCurrentUser,
            onEdit: isCurrentUser ? null : () => onEditUser(user.id!),
            onEditPassword: isCurrentUser ? null : () => onEditPassword(user),
            onDelete: isCurrentUser ? null : () => onDeleteUser(user),
            onResetPassword: isCurrentUser ? null : () => onResetPassword(user),
          );
        },
      ),
    );
  }
}