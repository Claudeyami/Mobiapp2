class Movie {
  final int id;
  final String title;
  final String? poster;
  final String? description;
  final String? genre;
  final String? slug;

  Movie({
    required this.id,
    required this.title,
    this.poster,
    this.description,
    this.genre,
    this.slug,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    
    final idValue = json['id'] ?? json['MovieID'] ?? json['movieId'] ?? json['movie_id'];
    if (idValue != null) {
      if (idValue is int) {
        parsedId = idValue;
      } else if (idValue is String) {
        parsedId = int.tryParse(idValue);
      } else if (idValue is double) {
        parsedId = idValue.toInt();
      }
    }
    
    if (parsedId == null) {
      throw FormatException('Movie id is required but was null or invalid. Available keys: ${json.keys.join(", ")}');
    }

    final title = json['title'] ?? json['Title'] ?? json['name'] ?? '';
    String? poster = json['poster'] ?? json['PosterURL'] ?? json['posterUrl'] ?? json['poster_url'];
    
    if (poster != null && poster.isNotEmpty && !poster.startsWith('http')) {
      final baseUrl = 'http://10.0.2.2:4000';
      if (poster.startsWith('/')) {
        poster = '$baseUrl$poster';
      } else {
        poster = '$baseUrl/$poster';
      }
    }
    
    final description = json['description'] ?? json['Description'] ?? json['desc'] ?? json['summary'];
    final genre = json['genre'] ?? json['Genre'] ?? json['category'];
    final slug = json['slug'] ?? json['Slug'];

    return Movie(
      id: parsedId,
      title: title,
      poster: poster,
      description: description,
      genre: genre,
      slug: slug,
    );
  }
}
