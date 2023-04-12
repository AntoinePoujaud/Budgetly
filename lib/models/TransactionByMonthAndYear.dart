class TransactionByMonthAndYear {
  int id;
  String date;
  String type;
  double amount;
  String description;
  int categoryId;
  String categoryName;
  String paymentMethod;

  TransactionByMonthAndYear({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.paymentMethod,
  });

  factory TransactionByMonthAndYear.fromJson(Map<String, dynamic> json) {
    return TransactionByMonthAndYear(
      id: json['id'],
      date: json['date'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      categoryId: json['catId'],
      categoryName: json['catName'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, String?> convertTransaction() {
    if (description == "null") {
      description = "";
    }
    return {
      "id": id.toString(),
      "date": date,
      "type": type,
      "amount": amount.toString(),
      "description": description,
      "catId": categoryId.toString(),
      "catName": categoryName,
      "paymentMethod": paymentMethod.toString(),
    };
  }
}
