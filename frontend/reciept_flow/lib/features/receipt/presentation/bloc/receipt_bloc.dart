import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/receipt_repository.dart';
import 'receipt_event.dart';
import 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final ReceiptRepository repo;

  ReceiptBloc(this.repo) : super(const ReceiptState()) {
    on<UploadReceipt>(_onUpload);
    on<UpdateReceipt>(_onUpdate);
    on<SaveReceipt>(_onSave);
    on<ResetReceipt>(_onReset);
  }

  Future<void> _onUpload(UploadReceipt event, Emitter<ReceiptState> emit) async {
    emit(state.copyWith(status: ReceiptStatus.loading));
    try {
      final receipt = await repo.parseReceipt(event.image);
      emit(state.copyWith(status: ReceiptStatus.success, receipt: receipt));
    } catch (e) {
      emit(state.copyWith(
        status: ReceiptStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdate(UpdateReceipt event, Emitter<ReceiptState> emit) {
    emit(state.copyWith(receipt: event.receipt));
  }

  Future<void> _onSave(SaveReceipt event, Emitter<ReceiptState> emit) async {
    if (state.receipt == null) return;
    emit(state.copyWith(status: ReceiptStatus.saving));
    try {
      await repo.saveReceipt(state.receipt!);
      emit(state.copyWith(status: ReceiptStatus.saved));
    } catch (e) {
      emit(state.copyWith(
        status: ReceiptStatus.error,
        errorMessage: 'Save failed: ${e.toString()}',
      ));
    }
  }

  void _onReset(ResetReceipt event, Emitter<ReceiptState> emit) {
    emit(const ReceiptState());
  }
}
