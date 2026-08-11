import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  static const String _key = 'cinema_central_favorites_v1';
  final ValueNotifier<List<Movie>> favoritesNotifier = ValueNotifier<List<Movie>>([]);

  List<Movie> get favorites => favoritesNotifier.value;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final movies = list.map((item) => Movie.fromJson(item as Map<String, dynamic>)).toList();
        favoritesNotifier.value = movies;
      }
    } catch (e) {
      debugPrint('Error initializing favorites: $e');
    }
  }

  bool isFavorite(int movieId) {
    return favoritesNotifier.value.any((m) => m.id == movieId);
  }

  Future<void> toggleFavorite(Movie movie) async {
    final current = List<Movie>.from(favoritesNotifier.value);
    final index = current.indexWhere((m) => m.id == movie.id);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(movie);
    }
    favoritesNotifier.value = current;
    await _saveToStorage(current);
  }

  Future<void> _saveToStorage(List<Movie> movies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = movies.map((m) => m.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
}
