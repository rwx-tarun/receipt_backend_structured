class LineItem {
  final String name;
  final double amount;

  LineItem({required this.name, required this.amount});

  LineItem copyWith({String? name, double? amount}) {
    return LineItem(
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount};
}
