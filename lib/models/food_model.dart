class Food{
  int? id;
  int userId;
  int categoryId;
  String name;
  String? description;
  String? imageUrl;
  String createdAt;
  String updatedAt;
  double? quantity;
  String? unit;

  Food({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.quantity,
    this.unit,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'quantity': quantity,
      'unit': unit,
    };
  }
}