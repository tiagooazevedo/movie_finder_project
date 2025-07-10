import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _apiKey = '600048bf786c815fbc748a148f476de2';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  static final Map<int, String> _genreMap = {};
  static bool _genresLoaded = false;

  static Future<void> _fetchGenres() async {
    if (_genresLoaded) return;
    
    try {
      final url = Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=pt-BR');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final genres = jsonDecode(response.body)['genres'] as List;
        _genreMap.addAll({for (var g in genres) g['id']: g['name']});
        _genresLoaded = true;
      }
    } catch (e) {
      throw Exception('Falha ao carregar gêneros: ${e.toString()}');
    }
  }

  static String imageUrl(String path, {String size = 'w500'}) {
    return '$_imageBaseUrl/$size$path';
  }

  static Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    
    try {
      await _fetchGenres();
      
      final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey'
        '&query=${Uri.encodeComponent(query)}'
        '&language=pt-BR'
        '&include_adult=false'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List results = jsonDecode(response.body)['results'];
        
        List<Movie> movies = results.map((json) {
          final genreIds = (json['genre_ids'] as List<dynamic>? ?? []);
          final genres = genreIds
              .map((id) => _genreMap[id] ?? '')
              .where((g) => g.isNotEmpty)
              .toList();
              
          return Movie.fromJson(json, genres: genres);
        }).where((movie) => movie.posterPath.isNotEmpty).toList();

        // Ordenação por ano de lançamento e depois por nome
        movies.sort((a, b) {
          if (a.releaseYear != b.releaseYear) {
            return (b.releaseYear ?? 0).compareTo(a.releaseYear ?? 0); // Mais recente primeiro
          }
          return a.title.compareTo(b.title);
        });

        return movies;
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na busca: ${e.toString()}');
    }
  }
}