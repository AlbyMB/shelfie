class Category{
  int? id;
  int userId;
  String name;

  Category({this.id, required this.userId, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
    };
  }
}