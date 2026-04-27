import 'line_item.dart';

class Receipt {
  final String merchant;
  final DateTime date;
  final List<LineItem> items;
  final double total;

  Receipt({
    required this.merchant,
    required this.date,
    required this.items,
    required this.total,
  });

  Receipt copyWith({
    String? merchant,
    DateTime? date,
    List<LineItem>? items,
    double? total,
  }) {
    return Receipt(
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() => {
        'merchant': merchant,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
      };
}
