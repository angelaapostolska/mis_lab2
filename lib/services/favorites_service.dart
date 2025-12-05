class FavoritesService {
  // singleton pattern in order to share one favorites list throughout the app
  static final FavoritesService _instance = FavoritesService._internal();

  factory FavoritesService() {
    return _instance;
  }

  FavoritesService._internal();

  final List<String> _favoriteMealIds = [];

  List<String> getFavorites() {
    return List.from(_favoriteMealIds);
  }

  bool addFavorite(String mealId) {
    if (!_favoriteMealIds.contains(mealId)) {
      _favoriteMealIds.add(mealId);
      return true;
    }
    return false;
  }

  bool removeFavorite(String mealId){
    if (_favoriteMealIds.contains(mealId)) {
      _favoriteMealIds.remove(mealId);
      return true;
    } else {
      return false;
    }
  }

  bool isFavorite(String mealId){
    return _favoriteMealIds.contains(mealId);
  }

  bool toggleFavorite(String mealId) {
    if (isFavorite(mealId)) {
      return removeFavorite(mealId);
    } else {
      return addFavorite(mealId);
    }
  }

  void clearFavorites() {
    _favoriteMealIds.clear();
  }

  int getFavoritesCount() {
    return _favoriteMealIds.length;
  }
}