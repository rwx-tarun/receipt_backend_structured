import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/line_item.dart';
import '../bloc/receipt_bloc.dart';
import '../bloc/receipt_event.dart';
import '../bloc/receipt_state.dart';

class ReceiptEditView extends StatelessWidget {
  const ReceiptEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiptBloc, ReceiptState>(
      listener: (context, state) {
        if (state.status == ReceiptStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt saved!'), backgroundColor: Colors.green),
          );
        }
        if (state.status == ReceiptStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Receipt'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            BlocBuilder<ReceiptBloc, ReceiptState>(
              builder: (context, state) {
                if (state.status == ReceiptStatus.saving) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Receipt',
                  onPressed: () => context.read<ReceiptBloc>().add(SaveReceipt()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ReceiptBloc, ReceiptState>(
          builder: (context, state) {
            if (state.receipt == null) {
              return const Center(child: Text('No receipt data'));
            }

            final receipt = state.receipt!;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Merchant
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      key: ValueKey(receipt.merchant),
                      initialValue: receipt.merchant,
                      decoration: const InputDecoration(
                        labelText: 'Merchant',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        context.read<ReceiptBloc>().add(
                              UpdateReceipt(receipt.copyWith(merchant: value)),
                            );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Date
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      key: ValueKey(receipt.date.toIso8601String()),
                      initialValue: receipt.date.toLocal().toString().split(' ')[0],
                      decoration: const InputDecoration(
                        labelText: 'Date (YYYY-MM-DD)',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final parsed = DateTime.tryParse(value);
                        if (parsed != null) {
                          context.read<ReceiptBloc>().add(
                                UpdateReceipt(receipt.copyWith(date: parsed)),
                              );
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Items header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                      tooltip: 'Add Item',
                      onPressed: () {
                        final updatedItems = List<LineItem>.from(receipt.items)
                          ..add(LineItem(name: '', amount: 0.0));
                        context.read<ReceiptBloc>().add(
                              UpdateReceipt(receipt.copyWith(items: updatedItems)),
                            );
                      },
                    ),
                  ],
                ),

                // Items list
                ...receipt.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              key: ValueKey('name_$index'),
                              initialValue: item.name,
                              decoration: const InputDecoration(
                                labelText: 'Item name',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                final updatedItems = List<LineItem>.from(receipt.items);
                                updatedItems[index] = item.copyWith(name: value);
                                context.read<ReceiptBloc>().add(
                                      UpdateReceipt(receipt.copyWith(items: updatedItems)),
                                    );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              key: ValueKey('amount_$index'),
                              initialValue: item.amount.toStringAsFixed(2),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                prefixText: '₹',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final amount = double.tryParse(value) ?? item.amount;
                                final updatedItems = List<LineItem>.from(receipt.items);
                                updatedItems[index] = item.copyWith(amount: amount);
                                context.read<ReceiptBloc>().add(
                                      UpdateReceipt(receipt.copyWith(items: updatedItems)),
                                    );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              final updatedItems = List<LineItem>.from(receipt.items)
                                ..removeAt(index);
                              context.read<ReceiptBloc>().add(
                                    UpdateReceipt(receipt.copyWith(items: updatedItems)),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Total
                Card(
                  color: Colors.deepPurple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      key: ValueKey(receipt.total),
                      initialValue: receipt.total.toStringAsFixed(2),
                      decoration: const InputDecoration(
                        labelText: 'Total',
                        prefixText: '₹',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final total = double.tryParse(value) ?? receipt.total;
                        context.read<ReceiptBloc>().add(
                              UpdateReceipt(receipt.copyWith(total: total)),
                            );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Receipt'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => context.read<ReceiptBloc>().add(SaveReceipt()),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Another'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    context.read<ReceiptBloc>().add(ResetReceipt());
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
