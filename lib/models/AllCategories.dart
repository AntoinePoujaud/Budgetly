class AllCategories {
  int id;
  String name;

  AllCategories({
    required this.id,
    required this.name,
  });

  factory AllCategories.fromJson(Map<String, dynamic> json) {
    return AllCategories(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, String?> convertTransaction() {
    return {
      "id": id.toString(),
      "name": name,
    };
  }
}
