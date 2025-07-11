import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/pages/home/home_page.dart';
import 'package:warmindo_app/presentation/pages/pos/pos_page.dart';
import 'package:warmindo_app/presentation/pages/transaction/transaction_history_page.dart';
import 'package:warmindo_app/presentation/pages/profile/profile_page.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final List<_BottomNavItem> _navItems;

  @override
  void initState() {
    super.initState();
    print('🏠 MainPage initState called');

    final authState = context.read<AuthBloc>().state;
    final isOwner = authState is AuthSuccess && authState.user.isOwner;

    _pages = [
      const HomePage(),
      const PosPage(),
      const TransactionHistoryPage(),
      const ProfilePage(),
    ];

    _navItems = [
      _BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Beranda',
      ),
      _BottomNavItem(
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale,
        label: 'Kasir',
      ),
      _BottomNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Riwayat',
      ),
      _BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
      ),
    ];

    // ✅ Load initial data untuk home page
    _refreshHomeData();
  }

  void _onTabTapped(int index) {
    print('🔄 Tab tapped: $index (current: $_currentIndex)');
    
    if (index == _currentIndex) {
      // ✅ Jika tap tab yang sama, refresh data (khusus untuk home)
      if (index == 0) {
        print('🔄 Double tap home tab - refreshing data');
        _refreshHomeData();
      }
    } else {
      // ✅ Pindah ke tab baru
      final oldIndex = _currentIndex;
      setState(() {
        _currentIndex = index;
      });

      // ✅ Auto refresh home data saat kembali ke home tab
      if (index == 0) {
        print('🔄 Switched to home tab - refreshing data');
        _refreshHomeData();
      }

      print('🔄 Tab switched from $oldIndex to $index');
    }
  }

  void _refreshHomeData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user.isOwner) {
      print('🔄 Refreshing home data...');
      
      // ✅ Beri delay kecil untuk memastikan UI ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<ReportBloc>().add(ReportLoadDashboard());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ✅ Handle back button
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        if (_currentIndex != 0) {
          // ✅ Jika tidak di home, pindah ke home
          print('🔄 Back pressed - switching to home tab');
          _onTabTapped(0);
        } else {
          // ✅ Exit app confirmation
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped, // ✅ Keep custom tap handler for refresh logic
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.white,
            selectedItemColor: AppTheme.primaryRed,
            unselectedItemColor: AppTheme.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: _navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ✅ Force exit app
              Navigator.of(context).pop();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}