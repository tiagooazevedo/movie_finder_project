class Movie {
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final List<String> genres;
  final int? releaseYear;

  Movie({
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genres,
  }) : releaseYear = releaseDate.isNotEmpty
          ? int.tryParse(releaseDate.split('-')[0])
          : null;

  factory Movie.fromJson(Map<String, dynamic> json, {List<String>? genres}) {
    return Movie(
      title: json['title'] ?? 'Sem título',
      overview: json['overview'] ?? 'Sinopse não disponível.',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genres: genres ?? (json['genre_ids'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  String get formattedReleaseDate {
    if (releaseDate.isEmpty) return 'Data desconhecida';
    final dateParts = releaseDate.split('-');
    if (dateParts.length >= 3) {
      return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
    }
    return releaseDate;
  }
}