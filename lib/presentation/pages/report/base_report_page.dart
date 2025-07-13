import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/pages/report/widgets/export_dialog_widget.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

// Base widget untuk semua halaman report dengan fitur umum seperti toggle view, export, dan refresh
class BaseReportPage extends StatefulWidget {
  final String title;
  final DateTime period;
  final VoidCallback onRefresh;
  final Widget Function(BuildContext context, String viewMode) builder;

  const BaseReportPage({
    Key? key,
    required this.title,
    required this.period,
    required this.onRefresh,
    required this.builder,
  }) : super(key: key);

  @override
  State<BaseReportPage> createState() => _BaseReportPageState();
}

class _BaseReportPageState extends State<BaseReportPage> {
  String _selectedView = 'chart'; // Mode tampilan: 'chart' atau 'table'

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Handler untuk navigasi kembali dengan callback
      onPopInvoked: (didPop) {
        if (didPop) {
          print('BaseReportPage popped, navigating back');
          // Delay kecil untuk memastikan navigation selesai
          Future.delayed(const Duration(milliseconds: 100), () {
            // Callback sudah ditangani di report_menu_widget
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              print('Back button pressed in ${widget.title}');
              Navigator.pop(context);
            },
          ),
          actions: [
            // Toggle button untuk switch antara chart dan table view
            IconButton(
              icon: Icon(
                _selectedView == 'chart' ? Icons.table_chart : Icons.show_chart,
              ),
              tooltip: _selectedView == 'chart' ? 'Tampilkan Tabel' : 'Tampilkan Chart',
              onPressed: () {
                setState(() {
                  _selectedView = _selectedView == 'chart' ? 'table' : 'chart';
                });
              },
            ),
            // Menu untuk export dan refresh
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'export') {
                  ExportDialogWidget.show(context, widget.period);
                } else if (value == 'refresh') {
                  print('Manual refresh triggered');
                  widget.onRefresh();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 8),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocConsumer<ReportBloc, ReportState>(
          listener: (context, state) {
            // Handle export success dan error states
            if (state is ReportExcelGenerated || state is ReportPDFGenerated) {
              ExportDialogWidget.showSuccessDialog(context, state);
            } else if (state is ReportFailure) {
              CustomDialog.showError(context: context, message: state.error);
            }
          },
          builder: (context, state) {
            print('BaseReportPage BlocBuilder state: ${state.runtimeType}');
            
            if (state is ReportLoading) {
              return const LoadingWidget();
            } else if (state is ReportFailure) {
              return _buildErrorState(state.error);
            }
            
            // Gunakan builder function untuk render content dinamis
            return RefreshIndicator(
              onRefresh: () async {
                print('Pull to refresh triggered');
                widget.onRefresh();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: widget.builder(context, _selectedView),
            );
          },
        ),
        // Floating action button untuk quick toggle view
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            setState(() {
              _selectedView = _selectedView == 'chart' ? 'table' : 'chart';
            });
          },
          tooltip: 'Toggle View',
          child: Icon(
            _selectedView == 'chart' ? Icons.table_chart : Icons.show_chart,
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan error state dengan opsi retry
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.grey,
                    foregroundColor: AppTheme.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: AppTheme.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}