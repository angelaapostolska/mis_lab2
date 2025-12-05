import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class FavoriteButton extends StatefulWidget {
  final String mealId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    Key? key,
    required this.mealId,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = _favoritesService.isFavorite(widget.mealId);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite
            ? (widget.activeColor ?? Colors.red)
            : (widget.inactiveColor ?? Colors.grey),
        size: widget.size,
      ),
      onPressed: () {
        _favoritesService.toggleFavorite(widget.mealId);

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? 'Removed from favorites'
                  : 'Added to favorites',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}