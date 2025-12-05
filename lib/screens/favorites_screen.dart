import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();

  List<MealDetail> _favoriteMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favoriteIds = _favoritesService.getFavorites();

      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteMeals = [];
          _isLoading = false;
        });
        return;
      }

      List<MealDetail> meals = [];
      for (String mealId in favoriteIds) {
        try {
          final meal = await _apiService.fetchMealDetails(mealId);
          meals.add(meal);
        } catch (e) {
          print('Error loading meal $mealId: $e');
        }
      }

      setState(() {
        _favoriteMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    }
  }

  void _removeFavorite(String mealId) {
    _favoritesService.removeFavorite(mealId);
    _loadFavorites();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
        backgroundColor: Colors.orange,
        actions: [
          if (_favoriteMeals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all favorites',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Favorites'),
                    content: const Text(
                      'Are you sure you want to remove all favorites?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  _favoritesService.clearFavorites();
                  _loadFavorites();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMeals.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add recipes to your favorites to see them here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _favoriteMeals.length,
        itemBuilder: (context, index) {
          final meal = _favoriteMeals[index];
          return _buildFavoriteCard(meal);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(MealDetail meal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealDetailScreen(
                mealId: meal.id,
                mealName: meal.name,
              ),
            ),
          );
          _loadFavorites();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.thumbnail,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            meal.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.orange[100],
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            meal.area,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue[100],
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _removeFavorite(meal.id),
                tooltip: 'Remove from favorites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}