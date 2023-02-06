class TransactionByMonthAndYear {
  int id;
  String date;
  String type;
  double amount;
  String description;
  int categoryId;

  TransactionByMonthAndYear({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
    required this.categoryId,
  });

  factory TransactionByMonthAndYear.fromJson(Map<String, dynamic> json) {
    return TransactionByMonthAndYear(
      id: json['id'],
      date: json['date'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      categoryId: json['catId'],
    );
  }

  Map<String, String?> convertTransaction() {
    return {
      "id": id.toString(),
      "date": date,
      "type": type,
      "amount": amount.toString(),
      "description": description,
      "catId": categoryId.toString(),
    };
  }
}
