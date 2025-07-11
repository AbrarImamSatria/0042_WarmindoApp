import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/pages/report/menu_performance_report_page.dart';
import 'package:warmindo_app/presentation/pages/report/payment_report_page.dart';
import 'package:warmindo_app/presentation/pages/report/sales_report_page.dart';
import 'package:warmindo_app/presentation/pages/auth/login_page.dart';
import 'package:warmindo_app/presentation/pages/main/main_page.dart';
import 'package:warmindo_app/presentation/pages/pos/pos_page.dart';
import 'package:warmindo_app/presentation/pages/pos/cart_page.dart';
import 'package:warmindo_app/presentation/pages/menu/menu_management_page.dart';
import 'package:warmindo_app/presentation/pages/menu/menu_form_page.dart';
import 'package:warmindo_app/presentation/pages/transaction/transaction_history_page.dart';
import 'package:warmindo_app/presentation/pages/transaction/transaction_detail_page.dart';
import 'package:warmindo_app/presentation/pages/profile/profile_page.dart';
import 'package:warmindo_app/presentation/pages/profile/map_picker_page.dart';
import 'package:warmindo_app/presentation/pages/profile/change_password_page.dart';
import 'package:warmindo_app/presentation/pages/report/report_page.dart';
import 'package:warmindo_app/presentation/pages/user/user_management_page.dart';
import 'package:warmindo_app/presentation/pages/user/user_form_page.dart';
import 'package:warmindo_app/presentation/pages/backup/backup_restore_page.dart';

class AppRouter {
  // Route names
  static const String login = '/login';
  static const String main = '/main';
  static const String pos = '/pos';
  static const String cart = '/cart';
  static const String menuManagement = '/menu-management';
  static const String menuForm = '/menu-form';
  static const String transactionHistory = '/transaction-history';
  static const String transactionDetail = '/transaction-detail';
  static const String profile = '/profile';
  static const String mapPicker = '/map-picker';
  static const String changePassword = '/change-password';
  static const String report = '/report';
  static const String userManagement = '/user-management';
  static const String userForm = '/user-form';
  static const String settings = '/settings';
  static const String backupRestore = '/backup-restore';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Handle report routes with specific patterns
    if (settings.name?.startsWith('/report') == true && settings.name != '/report') {
      return _handleReportRoutes(settings);
    }

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/main':
        return MaterialPageRoute(builder: (_) => const MainPage());

      case '/pos':
        return MaterialPageRoute(builder: (_) => const PosPage());

      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartPage());

      case '/menu-management':
        return MaterialPageRoute(builder: (_) => const MenuManagementPage());

      case '/menu-form':
        final menu = settings.arguments as MenuModel?;
        return MaterialPageRoute(builder: (_) => MenuFormPage(menu: menu));

      case '/transaction-history':
        return MaterialPageRoute(builder: (_) => const TransactionHistoryPage());

      case '/transaction-detail':
        final args = settings.arguments;
        
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => TransactionDetailPage(
              transactionId: args['transactionId'] as int,
              fromCart: args['fromCart'] as bool? ?? false,
            ),
          );
        } else if (args is int) {
          return MaterialPageRoute(
            builder: (_) => TransactionDetailPage(
              transactionId: args,
              fromCart: false,
            ),
          );
        } else {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('Invalid transaction detail arguments')),
            ),
          );
        }

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case '/map-picker':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MapPickerPage(
            initialLatitude: args?['latitude'] as double?,
            initialLongitude: args?['longitude'] as double?,
          ),
        );

      case '/change-password':
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());

      case '/report':
        return MaterialPageRoute(builder: (_) => const ReportPage());

      case '/user-management':
        return MaterialPageRoute(builder: (_) => const UserManagementPage());

      case '/user-form':
        final userId = settings.arguments as int?;
        return MaterialPageRoute(builder: (_) => UserFormPage(userId: userId));

      case '/backup-restore':
        return MaterialPageRoute(builder: (_) => const BackupRestorePage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Route<dynamic> _handleReportRoutes(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final period = args?['period'] ?? DateTime.now();

    switch (settings.name) {
      case '/report/sales':
        return MaterialPageRoute(
          builder: (_) => SalesReportPage(period: period),
        );

      case '/report/menu-performance':
      case '/report/best-selling':
        return MaterialPageRoute(
          builder: (_) => MenuPerformanceReportPage(period: period),
        );

      case '/report/payment':
        return MaterialPageRoute(
          builder: (_) => PaymentReportPage(period: period),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Report route not found: ${settings.name}')),
          ),
        );
    }
  }
}