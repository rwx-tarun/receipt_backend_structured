import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/receipt/data/receipt_repository.dart';
import 'features/receipt/presentation/bloc/receipt_bloc.dart';
import 'features/receipt/presentation/view/upload_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Parser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => ReceiptBloc(ReceiptRepository()),
        child: const UploadView(),
      ),
    );
  }
}
