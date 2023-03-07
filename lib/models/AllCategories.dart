class AllCategories {
  int id;
  String name;
  String type;

  AllCategories({
    required this.id,
    required this.name,
    required this.type,
  });

  factory AllCategories.fromJson(Map<String, dynamic> json) {
    return AllCategories(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, String?> convertTransaction() {
    return {
      "id": id.toString(),
      "name": name,
      "type": type,
    };
  }
}
