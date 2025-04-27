import 'package:shelfie/database/db_helper.dart';
import 'package:shelfie/models/category_model.dart';

class CategoryRepository {
  final DBHelper _dbHelper = DBHelper.dbHelper;

  Future<List<Category>> getAllCategories(int userId) async {
    final List<Map<String, dynamic>> categories = await _dbHelper.readDb('categories', whereField: 'userId', whereValue: userId);
    return List.generate(categories.length, (i) {
      return Category(
        id: categories[i]['id'],
        name: categories[i]['name'],
        userId: categories[i]['userId'],
        );
    });
  }


  Future<int> insertCategory(Category category) async {
    return await _dbHelper.insertDb(category.toMap(), 'categories');
  }


  Future<int> updateCategory(Category category, int id) async {
    return await _dbHelper.updateDb(category.toMap(), 'categories');
  }

  Future<int> deleteCategory(int id) async {
    return await _dbHelper.deleteDb(id, 'categories');
  }
}
