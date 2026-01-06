import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/movie_api_service.dart';

class MovieProvider with ChangeNotifier {
  final MovieApiService _api = MovieApiService();

  List<Movie> _movies = [];
  bool _loading = false;

  List<Movie> get movies => _movies;
  bool get loading => _loading;

  Future<void> fetchMovies() async {
    _loading = true;
    notifyListeners();

    try {
      _movies = await _api.getMovies();
    } catch (_) {}

    _loading = false;
    notifyListeners();
  }
}
