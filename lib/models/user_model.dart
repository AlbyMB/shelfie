class User{
  int? id;
  String? name;
  String email;
  String password;
  String? createdAt;
  String isLoggedIn = 'false';

  User({this.id, this.name, required this.email, required this.password, this.createdAt, this.isLoggedIn = 'false'});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'isLoggedIn': isLoggedIn,
    };
  }
}