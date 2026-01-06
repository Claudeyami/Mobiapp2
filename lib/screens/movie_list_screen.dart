import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_api_service.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final MovieApiService _apiService = MovieApiService();
  List<Movie> allMovies = [];
  List<Movie> filteredMovies = [];
  bool isLoading = true;
  bool hasError = false;
  String? selectedGenre;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      print('🔄 MovieListScreen: Fetching movies...');
      final result = await _apiService.getMovies();
      print('✅ MovieListScreen: Received ${result.length} movies');
      
      setState(() {
        allMovies = result;
        _applyFilter();
        isLoading = false;
        hasError = false;
      });
      
      if (result.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có phim nào trong hệ thống'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ MovieListScreen: Error fetching movies: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
      
      if (mounted) {
        String errorMsg = 'Không thể tải danh sách phim';
        if (e.toString().contains('SocketException') || e.toString().contains('connection')) {
          errorMsg = 'Không thể kết nối đến server. Kiểm tra lại kết nối mạng và đảm bảo backend đang chạy.';
        } else if (e.toString().contains('404')) {
          errorMsg = 'Endpoint không tồn tại. Kiểm tra lại URL API.';
        } else if (e.toString().contains('timeout')) {
          errorMsg = 'Kết nối timeout. Thử lại sau.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _applyFilter() {
    if (selectedGenre == null || selectedGenre == 'Tất cả') {
      filteredMovies = allMovies;
    } else {
      filteredMovies = allMovies
          .where((movie) {
            if (movie.genre == null || movie.genre!.isEmpty) {
              return false;
            }
            final movieGenre = movie.genre!.toLowerCase();
            final selected = selectedGenre!.toLowerCase();
            
            if (selected == 'hành động' || selected == 'hanh dong') {
              return movieGenre.contains('hành động') || 
                     movieGenre.contains('hanh dong') ||
                     movieGenre.contains('action');
            } else if (selected == 'tình cảm' || selected == 'tinh cam') {
              return movieGenre.contains('tình cảm') || 
                     movieGenre.contains('tinh cam') ||
                     movieGenre.contains('romance') ||
                     movieGenre.contains('love');
            } else if (selected == 'viễn tưởng' || selected == 'vien tuong') {
              return movieGenre.contains('viễn tưởng') || 
                     movieGenre.contains('vien tuong') ||
                     movieGenre.contains('sci-fi') ||
                     movieGenre.contains('science fiction');
            } else if (selected == 'kinh dị' || selected == 'kinh di') {
              return movieGenre.contains('kinh dị') || 
                     movieGenre.contains('kinh di') ||
                     movieGenre.contains('horror') ||
                     movieGenre.contains('thriller');
            } else if (selected == 'phiêu lưu' || selected == 'phieu luu') {
              return movieGenre.contains('phiêu lưu') || 
                     movieGenre.contains('phieu luu') ||
                     movieGenre.contains('adventure');
            }
            
            return movieGenre == selected;
          })
          .toList();
    }
  }

  List<String> get _availableGenres {
    return [
      'Tất cả',
      'Hành động',
      'Tình cảm',
      'Viễn tưởng',
      'Kinh dị',
      'Phiêu lưu',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie App'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 20, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Thể loại:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.purple.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedGenre ?? 'Tất cả',
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.purple.shade700),
                        style: TextStyle(
                          color: Colors.purple.shade900,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        items: _availableGenres.map((genre) {
                          final isSelected = (selectedGenre ?? 'Tất cả') == genre;
                          return DropdownMenuItem<String>(
                            value: genre,
                            child: Row(
                              children: [
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.purple.shade700,
                                  )
                                else
                                  const SizedBox(width: 18),
                                const SizedBox(width: 8),
                                Text(
                                  genre,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: isLoading
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  selectedGenre = newValue;
                                  _applyFilter();
                                });
                              },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchMovies,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Có lỗi xảy ra',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: fetchMovies,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : filteredMovies.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.movie_outlined,
                                      size: 80,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      allMovies.isEmpty
                                          ? 'Chưa có phim nào'
                                          : 'Không có phim thuộc thể loại này',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kéo xuống để làm mới',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredMovies.length,
                              itemBuilder: (context, index) {
                                final movie = filteredMovies[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (movie.id <= 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('ID phim không hợp lệ'),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        return;
                                      }
                                      
                                      print('🔍 [NAVIGATE] Opening movie detail for ID: ${movie.id}');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              MovieDetailScreen(movieId: movie.id),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: movie.poster != null
                                                ? Image.network(
                                                    movie.poster!,
                                                    width: 80,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: 80,
                                                        height: 120,
                                                        color:
                                                            Colors.grey.shade300,
                                                        child: const Icon(
                                                          Icons.movie,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    width: 80,
                                                    height: 120,
                                                    color: Colors.grey.shade300,
                                                    child: const Icon(
                                                      Icons.movie,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 16),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  movie.title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (movie.genre != null) ...[
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.purple.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Text(
                                                      movie.genre!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .purple.shade700,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                if (movie.description !=
                                                    null) ...[
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    movie.description!,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchMovies,
        child: const Icon(Icons.refresh),
        tooltip: 'Làm mới',
      ),
    );
  }
}
