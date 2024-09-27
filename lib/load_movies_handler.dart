import 'package:datasource/datasource.dart';
import 'package:domain/domain.dart';
import 'package:movie_info_provider/movie_info_provider.dart';

class LoadMoviesHandler {
  LoadMoviesHandler({
    required MovieInfoProvider Function(
      Settings settings,
      String tmdbApiKey,
    ) moviesProvider,
    required String? tmdbApiKey,
    required DataSource ds,
  })  : _moviesProvider = moviesProvider,
        _tmdbApiKey = tmdbApiKey,
        _ds = ds;

  final MovieInfoProvider Function(Settings settings, String tmdbApiKey)
      _moviesProvider;
  final String? _tmdbApiKey;
  final DataSource _ds;

  Future<void> loadMovies() async {
    final settings = await _ds.getSettings();
    if (settings == null) {
      throw Exception('settings is null');
    }
    final tmdbApiKey =
        (settings.tmdbApiKey == null || settings.tmdbApiKey!.isEmpty)
            ? _tmdbApiKey
            : settings.tmdbApiKey;
    if (tmdbApiKey == null || tmdbApiKey.isEmpty) {
      throw Exception('tmdbApiKey is null');
    }

    final moviesProvider = _moviesProvider(settings, tmdbApiKey);
    final movies = await moviesProvider.getMovies();
    await _ds.updateMovies(
      settings.imageBaseUrl == null || settings.imageBaseUrl!.isEmpty
          ? (await moviesProvider.getImageBasePath())
          : settings.imageBaseUrl,
      movies,
    );
  }
}
