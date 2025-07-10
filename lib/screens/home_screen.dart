import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/search_app_bar.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasSearched = false;

  Future<void> _searchMovies() async {
    if (_controller.text.trim().isEmpty) return;
    
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final movies = await ApiService.searchMovies(_controller.text.trim());
      
      setState(() {
        _movies = movies;
        if (movies.isEmpty) {
          _errorMessage = 'Nenhum filme encontrado para "${_controller.text}"';
        }
      });
    } on PlatformException catch (e) {
      setState(() => _errorMessage = 'Erro: ${e.message}');
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao buscar filmes');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _controller.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _movies = [];
      _errorMessage = '';
      _hasSearched = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SearchAppBar(
        controller: _controller,
        onSearch: _searchMovies,
        onClear: _clearSearch,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _searchMovies,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Busque por filmes, séries ou atores',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Text(
          'Nenhum resultado encontrado',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _movies.length,
      itemBuilder: (_, index) => MovieCard(
        movie: _movies[index],
        onTap: () => _navigateToDetail(_movies[index]),
      ),
    );
  }

  void _navigateToDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }
}