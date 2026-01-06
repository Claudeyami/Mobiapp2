import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../models/movie.dart';
import '../models/comment.dart';

class MovieApiService {
  final ApiClient _api = ApiClient();

  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('user_id');
    } catch (e) {
      print('⚠️ Error getting user ID: $e');
      return null;
    }
  }

  Future<List<Movie>> getMovies() async {
    try {
      print('📡 Calling API: GET /movies');
      final response = await _api.get('/movies');
      print('✅ API Response status: ${response.statusCode}');
      print('📦 Response data type: ${response.data.runtimeType}');
      print('📦 Response data: ${response.data}');

      final List data;
      if (response.data is List) {
        data = response.data as List;
        print('✅ Response is List with ${data.length} items');
      } else if (response.data is Map) {
        final mapData = response.data as Map;
        print('📋 Response is Map with keys: ${mapData.keys}');
        data = mapData['data'] ?? mapData['movies'] ?? mapData['items'] ?? [];
        print('✅ Extracted data with ${data.length} items');
      } else {
        print('❌ Unexpected response data type');
        throw Exception('Unexpected response format: ${response.data.runtimeType}');
      }

      if (data.isEmpty) {
        print('⚠️ API returned empty list');
        return [];
      }

      final List<Movie> movies = [];
      for (var i = 0; i < data.length; i++) {
        try {
          final item = data[i];
          print('🔄 Parsing movie ${i + 1}/${data.length}: $item');
          movies.add(Movie.fromJson(item));
        } catch (e) {
          print('❌ Error parsing movie ${i + 1}: $e');
          print('   Data: $data[i]');
        }
      }
      
      print('✅ Successfully parsed ${movies.length}/${data.length} movies');
      return movies;
    } catch (e) {
      print('❌ Get movies error: $e');
      if (e is DioException) {
        print('   Status code: ${e.response?.statusCode}');
        print('   Response data: ${e.response?.data}');
        print('   Error type: ${e.type}');
        print('   Error message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<Movie?> getMovieDetail(int id) async {
    if (id <= 0) {
      print('⚠️ Invalid movie ID: $id (must be > 0)');
      return null;
    }

    print('🔍 [MONITOR] Requesting movie detail for ID: $id');
    final startTime = DateTime.now();

    try {
      print('📡 Getting movie detail: GET /movies/$id');
      final res = await _api.get('/movies/$id');
      
      print('📦 Response status: ${res.statusCode}');
      print('📦 Response data type: ${res.data.runtimeType}');
      
      if (res.data == null) {
        print('⚠️ Response data is null');
        return null;
      }

      try {
        final movie = Movie.fromJson(res.data);
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        print('✅ Movie ID $id found (${duration}ms)');
        print('   → Movie title: ${movie.title}');
        return movie;
      } catch (parseError) {
        print('❌ Failed to parse movie from response: $parseError');
        print('   → Response data: ${res.data}');
        return null;
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        print('⚠️ [404] Movie ID $id not found');
        print('   → Trying fallback: get from movie list...');
        
        try {
          final allMovies = await getMovies();
          final movie = allMovies.firstWhere(
            (m) => m.id == id,
            orElse: () => throw Exception('Movie not found in list'),
          );
          print('✅ [FALLBACK] Found movie ID $id in list: ${movie.title}');
          return movie;
        } catch (fallbackError) {
          print('❌ [FALLBACK] Movie ID $id not found in list: $fallbackError');
          return null;
        }
      } else {
        print('❌ Get movie detail error: Status $statusCode');
        print('   → Response: ${e.response?.data}');
        return null;
      }
    } catch (e) {
      print('❌ Get movie detail error: $e');
      return null;
    }
  }

  Future<List<Comment>> getComments(int movieId) async {
    try {
      print('📡 Getting comments: GET /movies/$movieId/comments');
      final res = await _api.get('/movies/$movieId/comments');
      
      final List data = res.data is List 
          ? res.data 
          : (res.data is Map 
              ? (res.data['data'] ?? res.data['comments'] ?? res.data['items'] ?? [])
              : []);

      final List<Comment> comments = [];
      for (var item in data) {
        try {
          comments.add(Comment.fromJson(item));
        } catch (e) {
          print('Error parsing comment: $e, data: $item');
        }
      }
      print('✅ Successfully loaded ${comments.length} comments');
      return comments;
    } catch (e) {
      print('❌ Get comments error: $e');
      return [];
    }
  }

  Future<bool> addComment(int movieId, String content) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        print('⚠️ User ID not found. Cannot add comment.');
        return false;
      }

      print('📡 Adding comment: POST /movies/$movieId/comments');
      print('   → UserID: $userId, MovieID: $movieId');
      
      final res = await _api.post(
        '/movies/$movieId/comments',
        data: {
          'content': content,
          'userId': userId,
          'movieId': movieId,
        },
      );
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        print('✅ Comment added successfully');
        print('   → Response: ${res.data}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Add comment error: $e');
      if (e is DioException) {
        print('   → Status: ${e.response?.statusCode}');
        print('   → Response: ${e.response?.data}');
      }
      return false;
    }
  }

  Future<List<Movie>> searchMovies(String keyword) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    try {
      final encodedKeyword = Uri.encodeComponent(keyword.trim());
      print('📡 Searching movies: GET /movies/search?q=$encodedKeyword');
      final res = await _api.get('/movies/search?q=$encodedKeyword');

      final List data;
      if (res.data is List) {
        data = res.data as List;
      } else if (res.data is Map) {
        final mapData = res.data as Map;
        data = mapData['data'] ?? 
               mapData['movies'] ?? 
               mapData['items'] ?? 
               mapData['results'] ?? 
               [];
      } else {
        print('⚠️ Unexpected search response format: ${res.data.runtimeType}');
        return [];
      }

      print('✅ Found ${data.length} movies in search results');

      final List<Movie> movies = [];
      for (var item in data) {
        try {
          movies.add(Movie.fromJson(item));
        } catch (e) {
          print('❌ Error parsing movie in search: $e');
          print('   Data: $item');
        }
      }
      
      print('✅ Successfully parsed ${movies.length}/${data.length} movies');
      return movies;
    } catch (e) {
      print('❌ Search error: $e');
      if (e is DioException) {
        print('   → Status: ${e.response?.statusCode}');
        print('   → Response: ${e.response?.data}');
      }
      return [];
    }
  }

  Future<bool> rateMovie(int movieId, int score) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        print('⚠️ User ID not found. Cannot rate movie.');
        return false;
      }

      print('📡 Rating movie: POST /movies/$movieId/rating');
      print('   → UserID: $userId, MovieID: $movieId, Score: $score');
      
      final res = await _api.post(
        '/movies/$movieId/rating',
        data: {
          'score': score,
          'rating': score,
          'userId': userId,
          'movieId': movieId,
        },
      );
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        print('✅ Rating submitted successfully');
        print('   → Response: ${res.data}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Rating error: $e');
      if (e is DioException) {
        print('   → Status: ${e.response?.statusCode}');
        print('   → Response: ${e.response?.data}');
      }
      return false;
    }
  }

  Future<String?> getMovieVideoUrl(int movieId, {String? slug}) async {
    try {
      String endpoint;
      if (slug != null && slug.isNotEmpty) {
        endpoint = '/movies/$slug/episodes';
        print('📡 Getting video URL: GET /movies/$slug/episodes (using slug)');
      } else {
        endpoint = '/movies/$movieId/episodes';
        print('📡 Getting video URL: GET /movies/$movieId/episodes (using ID)');
      }
      final res = await _api.get(endpoint);
      
      print('📦 Video response status: ${res.statusCode}');
      print('📦 Video response data type: ${res.data.runtimeType}');
      
      if (res.data is List && (res.data as List).isNotEmpty) {
        final firstEpisode = (res.data as List)[0];
        if (firstEpisode is Map) {
          final videoUrl = firstEpisode['VideoURL'] ?? 
                         firstEpisode['videoUrl'] ?? 
                         firstEpisode['video_url'] ?? 
                         firstEpisode['url'] ??
                         firstEpisode['episodeUrl'] ??
                         firstEpisode['episode_url'];
          if (videoUrl != null && videoUrl is String && videoUrl.isNotEmpty) {
            String finalUrl = videoUrl;
            if (!finalUrl.startsWith('http')) {
              final baseUrl = 'http://10.0.2.2:4000';
              if (finalUrl.startsWith('/')) {
                finalUrl = '$baseUrl$finalUrl';
              } else {
                finalUrl = '$baseUrl/$finalUrl';
              }
            }
            print('✅ Video URL found: $finalUrl');
            return finalUrl;
          }
        }
      } else if (res.data is Map) {
        final data = res.data as Map;
        final videoUrl = data['VideoURL'] ?? 
                       data['videoUrl'] ?? 
                       data['video_url'] ?? 
                       data['url'] ??
                       data['episodeUrl'] ??
                       data['episode_url'];
        if (videoUrl != null && videoUrl is String && videoUrl.isNotEmpty) {
          String finalUrl = videoUrl;
          if (!finalUrl.startsWith('http')) {
            final baseUrl = 'http://10.0.2.2:4000';
            if (finalUrl.startsWith('/')) {
              finalUrl = '$baseUrl$finalUrl';
            } else {
              finalUrl = '$baseUrl/$finalUrl';
            }
          }
          print('✅ Video URL found: $finalUrl');
          return finalUrl;
        }
      }
      
      print('⚠️ Video URL not found in response');
      return null;
    } catch (e) {
      print('❌ Get video error: $e');
      if (e is DioException) {
        print('   → Status: ${e.response?.statusCode}');
        print('   → Response: ${e.response?.data}');
      }
      return null;
    }
  }
}
