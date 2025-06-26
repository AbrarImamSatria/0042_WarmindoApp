import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/data/repository/item_transaksi_repository.dart';
import 'package:warmindo_app/data/repository/transaksi_repository.dart';
import '../auth/auth_bloc.dart';

part 'transaction_history_event.dart';
part 'transaction_history_state.dart';

class TransactionHistoryBloc extends Bloc<TransactionHistoryEvent, TransactionHistoryState> {
  final TransaksiRepository _transaksiRepository = TransaksiRepository();
  final ItemTransaksiRepository _itemTransaksiRepository = ItemTransaksiRepository();
  final AuthBloc _authBloc;

  TransactionHistoryBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(TransactionHistoryInitial()) {
    on<TransactionHistoryLoad>(_onLoad);
    on<TransactionHistoryLoadByDate>(_onLoadByDate);
    on<TransactionHistoryLoadDetail>(_onLoadDetail);
    on<TransactionHistoryDelete>(_onDelete);
  }

  // Load transactions based on user role
  Future<void> _onLoad(TransactionHistoryLoad event, Emitter<TransactionHistoryState> emit) async {
    emit(TransactionHistoryLoading());
    try {
      final user = _authBloc.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      List<TransaksiModel> transactions;
      
      if (user.isEmployee) {
        // Karyawan hanya lihat transaksi hari ini yang dia buat
        transactions = await _transaksiRepository.getTransaksiByUser(user.id!, user.role);
      } else {
        // Pemilik lihat semua transaksi
        transactions = await _transaksiRepository.getAllTransaksi();
      }

      emit(TransactionHistorySuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionHistoryFailure(error: e.toString()));
    }
  }

  // Load by date range (Owner only)
  Future<void> _onLoadByDate(TransactionHistoryLoadByDate event, Emitter<TransactionHistoryState> emit) async {
    if (!_authBloc.isOwner) {
      emit(TransactionHistoryFailure(error: 'Hanya pemilik yang dapat filter berdasarkan tanggal'));
      return;
    }

    emit(TransactionHistoryLoading());
    try {
      final transactions = await _transaksiRepository.getTransaksiByDateRange(
        event.startDate,
        event.endDate,
      );
      emit(TransactionHistorySuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionHistoryFailure(error: e.toString()));
    }
  }

  // Load transaction detail
  Future<void> _onLoadDetail(TransactionHistoryLoadDetail event, Emitter<TransactionHistoryState> emit) async {
    emit(TransactionHistoryLoading());
    try {
      final detail = await _transaksiRepository.getTransaksiDetail(event.transactionId);
      
      if (detail != null) {
        emit(TransactionHistoryDetailLoaded(
          transaction: detail['transaksi'] as TransaksiModel,
          items: detail['items'] as List<ItemTransaksiModel>,
        ));
      } else {
        emit(TransactionHistoryFailure(error: 'Transaksi tidak ditemukan'));
      }
    } catch (e) {
      emit(TransactionHistoryFailure(error: e.toString()));
    }
  }

  // Delete transaction (Owner only)
  Future<void> _onDelete(TransactionHistoryDelete event, Emitter<TransactionHistoryState> emit) async {
    if (!_authBloc.isOwner) {
      emit(TransactionHistoryFailure(error: 'Hanya pemilik yang dapat menghapus transaksi'));
      return;
    }

    emit(TransactionHistoryLoading());
    try {
      await _transaksiRepository.deleteTransaksi(event.transactionId);
      
      // Reload transactions
      add(TransactionHistoryLoad());
    } catch (e) {
      emit(TransactionHistoryFailure(error: e.toString()));
    }
  }
}