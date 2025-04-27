import 'package:shelfie/database/db_helper.dart';
import 'package:shelfie/models/food_model.dart';

class FoodRepository {
  final DBHelper _dbHelper = DBHelper.dbHelper;

  Future<List<Food>> getAllFoods(int userId) async {
    final List<Map<String, dynamic>> foods = await _dbHelper.readDb('foods', whereField: 'userId', whereValue: userId);
    print(foods);
    return List.generate(foods.length, (i) {
      return Food(
        id: foods[i]['id'],
        userId: foods[i]['userId'],
        categoryId: foods[i]['categoryId'],
        name: foods[i]['name'],
        description: foods[i]['description'],
        imageUrl: foods[i]['imageUrl'],
        createdAt: foods[i]['createdAt'],
        updatedAt: foods[i]['updatedAt'],
        quantity: double.tryParse(foods[i]['quantity'].toString()),
        unit: foods[i]['unit'],
        );
    });
  }


  Future<int> insertFood(Food food) async {
    return await _dbHelper.insertDb(food.toMap(), 'foods');
  }


  Future<int> updateFood(Food food) async {
    return await _dbHelper.updateDb(food.toMap(), 'foods');
  }

  Future<int> deleteFood(int id) async {
    return await _dbHelper.deleteDb(id, 'foods');
  }
}
