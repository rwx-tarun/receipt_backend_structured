import 'dart:io';
import '../../domain/models/receipt.dart';

abstract class ReceiptEvent {}

class UploadReceipt extends ReceiptEvent {
  final File image;
  UploadReceipt(this.image);
}

class UpdateReceipt extends ReceiptEvent {
  final Receipt receipt;
  UpdateReceipt(this.receipt);
}

class SaveReceipt extends ReceiptEvent {}

class ResetReceipt extends ReceiptEvent {}
