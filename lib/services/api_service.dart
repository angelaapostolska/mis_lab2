import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';

class ApiService {
  // api base url
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/categories.php'),
      );

      if (response.statusCode == 200) {
        // decode the JSON'S response
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> categoriesJson = data['categories'];

        // convert the json into a Category object
        return categoriesJson.map((json) =>  Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
  } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // fetch meals by category
  Future<List<Meal>> fetchMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> mealsJson = data['meals'] ?? [];
        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      throw Exception('Error fetching meals: $e');
    }
  }

  // search meals by name
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final Map<String,dynamic> data = json.decode(response.body);
        final List<dynamic>? mealsJson = data['meals'];

        // empty result
        if (mealsJson == null) {
          return [];
        }

        return mealsJson.map((json) => Meal.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search meals');
      }
    } catch (e) {
      throw Exception('Error searching meals: $e');
    }
  }

  // fetch meal details
  Future<MealDetail> fetchMealDetails(String mealId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$mealId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? mealsJson = data['meals'];

        // meal returned
        if (mealsJson == null || mealsJson.isEmpty) {
          throw Exception('Meal not found');
        }

        return MealDetail.fromJson(mealsJson[0]);
      } else {
        throw Exception('Failed to load meal details');
      }
    } catch (e) {
      throw Exception('Error fetching meal details: $e');
    }
  }

  // fetch random meal
Future<MealDetail> fetchRandomMeal() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/random.php'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? mealsJson = data['meals'];

        if (mealsJson == null || mealsJson.isEmpty) {
          throw Exception('No random meal found');
        }

        return MealDetail.fromJson(mealsJson[0]);
      } else {
        throw Exception('Failed to load random meal');
      }
    } catch (e) {
      throw Exception('Error fetching random meal: $e');
    }

}
}