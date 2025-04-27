import 'package:shelfie/database/db_helper.dart';
import 'package:shelfie/models/user_model.dart';

class UserRepository {
  final DBHelper _dbHelper = DBHelper.dbHelper;

  // Retrieve all users
  Future<List<User>> getAllUsers() async {
    final List<Map<String, dynamic>> users = await _dbHelper.readDb('users');
    return List.generate(users.length, (i) {
      return User(
        id: users[i]['id'],
        name: users[i]['name'],
        email: users[i]['email'],
        password: users[i]['password'],
        createdAt: users[i]['createdAt'],
        isLoggedIn: users[i]['isLoggedIn']
        );
    });
  }

  Future<List<User>> getLoggedInUser() async {
    final List<Map<String, dynamic>> users = await _dbHelper.readDb('users', whereField: 'isLoggedIn', whereString: 'true');
    return List.generate(users.length, (i) {
      return User(
        id: users[i]['id'],
        name: users[i]['name'],
        email: users[i]['email'],
        password: users[i]['password'],
        createdAt: users[i]['createdAt'],
        isLoggedIn: users[i]['isLoggedIn']
        );
    });
  }

  Future<List<User>> getUserByEmail(String emailAddress) async {
    final List<Map<String, dynamic>> users = await _dbHelper.readDb('users', whereField: 'email', whereString: emailAddress);
    return List.generate(users.length, (i) {
      return User(
        id: users[i]['id'],
        name: users[i]['name'],
        email: users[i]['email'],
        password: users[i]['password'],
        createdAt: users[i]['createdAt'],
        isLoggedIn: users[i]['isLoggedIn']
        );
    });
  }

  // Insert a user
  Future<int> insertUser(User user) async {
    return await _dbHelper.insertDb(user.toMap(), 'users');
  }

  // Update a user
  Future<int> updateUser(User user, int id) async {
    return await _dbHelper.updateDb(user.toMap(), 'users');
  }

  // Delete a user
  Future<int> deleteUser(int id) async {
    return await _dbHelper.deleteDb(id, 'users');
  }
}
