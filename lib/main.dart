import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/backup/backup_bloc.dart';
import 'package:warmindo_app/bloc/menu/menu_bloc.dart';
import 'package:warmindo_app/bloc/pos/pos_bloc.dart';
import 'package:warmindo_app/bloc/print/print_bloc.dart';
import 'package:warmindo_app/bloc/profile/profile_bloc.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/bloc/transactionhistory/transaction_history_bloc.dart';
import 'package:warmindo_app/bloc/usermanagement/user_management_bloc.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  runApp(const WarmindoApp());
}

class WarmindoApp extends StatelessWidget {
  const WarmindoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckStatus()),
        ),

        BlocProvider<MenuBloc>(
          create: (context) => MenuBloc(
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<PosBloc>(
          create: (context) => PosBloc(
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<TransactionHistoryBloc>(
          create: (context) => TransactionHistoryBloc(
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<ReportBloc>(
          create: (context) => ReportBloc(
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<UserManagementBloc>(
          create: (context) => UserManagementBloc(
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<BackupBloc>(
          create: (context) => BackupBloc(
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<PrintBloc>(
          create: (context) => PrintBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Warmindo POS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}