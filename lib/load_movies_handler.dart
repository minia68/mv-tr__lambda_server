import 'package:datasource/datasource.dart';
import 'package:domain/domain.dart';
import 'package:lambda_server/notification_service.dart';
import 'package:lambda_server/watchlist_service.dart';
import 'package:movie_info_provider/movie_info_provider.dart';

class LoadMoviesHandler {
  LoadMoviesHandler({
    required MovieInfoProvider Function(Settings settings) moviesProvider,
    required DataSource datasource,
    required NotificationService notificationService,
    required WatchlistService watchlistService,
  })  : _moviesProvider = moviesProvider,
        _datasource = datasource,
        _notificationService = notificationService,
        _watchlistService = watchlistService;

  final MovieInfoProvider Function(Settings settings) _moviesProvider;
  final DataSource _datasource;
  final NotificationService _notificationService;
  final WatchlistService _watchlistService;

  Future<void> loadMovies() async {
    final settings = await _datasource.getSettings();
    if (settings == null) {
      throw Exception('settings is null');
    }

    final moviesProvider = _moviesProvider(settings);
    final movies = await moviesProvider.getMovies();
    await _datasource.updateMovies(
      settings.imageBaseUrl == null || settings.imageBaseUrl!.isEmpty
          ? (await moviesProvider.getImageBasePath())
          : settings.imageBaseUrl,
      movies,
    );
    if (settings.watchlistId != null &&
        settings.watchlistId!.isNotEmpty &&
        settings.chatId != null &&
        settings.chatId!.isNotEmpty) {
      await checkWatchlist(movies, settings.watchlistId!, settings.chatId!);
    }
  }

  Future<void> checkWatchlist(
    List<MovieInfo> movies,
    String listId,
    String chatId,
  ) async {
    final ids = await _watchlistService.getListMoviesIds(listId);
    for (final id in ids) {
      final idx = movies.indexWhere((e) => e.tmdbId.toString() == id);
      if (idx != -1) {
        final movie = movies[idx];
        await _notificationService.sendMessage(
          chatId,
          '<a href="https://minia68.github.io/index1.html?$id">${movie.title}</a>',
        );
      }
    }
  }
}
