import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/receipt_bloc.dart';
import '../bloc/receipt_event.dart';
import '../bloc/receipt_state.dart';
import 'receipt_edit_view.dart';

class UploadView extends StatelessWidget {
  const UploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiptBloc, ReceiptState>(
      listener: (context, state) {
        if (state.status == ReceiptStatus.success) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BlocProvider.value(
              value: context.read<ReceiptBloc>(),
              child: const ReceiptEditView(),
            )),
          );
        }
        if (state.status == ReceiptStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receipt Parser'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: BlocBuilder<ReceiptBloc, ReceiptState>(
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, size: 100, color: Colors.deepPurple),
                    const SizedBox(height: 24),
                    const Text(
                      'Upload a receipt to extract and edit its data',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    if (state.status == ReceiptStatus.loading)
                      const CircularProgressIndicator()
                    else ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick from Gallery'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(220, 50),
                        ),
                        onPressed: () => _pickImage(context, ImageSource.gallery),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take a Photo'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(220, 50),
                        ),
                        onPressed: () => _pickImage(context, ImageSource.camera),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null && context.mounted) {
      context.read<ReceiptBloc>().add(UploadReceipt(File(image.path)));
    }
  }
}
