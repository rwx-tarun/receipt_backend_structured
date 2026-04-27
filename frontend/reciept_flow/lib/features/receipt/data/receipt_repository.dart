import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../domain/models/line_item.dart';
import '../domain/models/receipt.dart';

class ReceiptRepository {
  final String baseUrl;
  late final Dio dio;

  ReceiptRepository({this.baseUrl = 'http://10.0.2.2:3000'}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // ✅ Add logging interceptor
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  Future<Receipt> parseReceipt(File image) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
      });

      final response = await dio.post('/receipts/parse', data: formData);

      final data = response.data;

      return Receipt(
        merchant: data['merchant'] ?? 'Unknown',
        date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
        items: (data['items'] as List? ?? [])
            .map(
              (e) => LineItem(
                name: e['name'] ?? '',
                amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
              ),
            )
            .toList(),
        total: (data['total'] as num?)?.toDouble() ?? 0.0,
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to parse receipt: ${e.response?.statusCode} ${e.message}',
      );
    }
  }

  Future<void> saveReceipt(Receipt receipt) async {
    try {
      final response = await dio.post('/receipts/save', data: receipt.toJson());

      if (response.statusCode != 200) {
        throw Exception('Failed to save receipt: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to save receipt: ${e.response?.statusCode} ${e.message}',
      );
    }
  }
}
