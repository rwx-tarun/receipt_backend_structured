import '../../domain/models/receipt.dart';

enum ReceiptStatus { initial, loading, success, saving, saved, error }

class ReceiptState {
  final ReceiptStatus status;
  final Receipt? receipt;
  final String? errorMessage;

  const ReceiptState({
    this.status = ReceiptStatus.initial,
    this.receipt,
    this.errorMessage,
  });

  ReceiptState copyWith({
    ReceiptStatus? status,
    Receipt? receipt,
    String? errorMessage,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
