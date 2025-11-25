class Meal {
  final String id;
  final String name;
  final String thumbnail;


  Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  // convert json to Meal object
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
    id: json['idMeal'] ?? '',
    name: json['strMeal'] ?? '',
    thumbnail: json['strMealThumb'] ?? '',
    );
  }
}