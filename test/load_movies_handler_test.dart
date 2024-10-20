// ignore_for_file: unnecessary_lambdas

import 'package:datasource/datasource.dart';
import 'package:domain/domain.dart';
import 'package:lambda_server/load_movies_handler.dart';
import 'package:lambda_server/notification_service.dart';
import 'package:lambda_server/watchlist_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_info_provider/movie_info_provider.dart';
import 'package:test/test.dart';

void main() {
  test('loadMovies settings is null', () async {
    final mip = MockMovieInfoProvider();
    final ds = MockDataSource();
    final handler = LoadMoviesHandler(
      datasource: ds,
      moviesProvider: (_) => mip,
      notificationService: MockNotificationService(),
      watchlistService: MockWatchlistService(),
    );

    when(() => ds.getSettings()).thenAnswer((_) async => null);
    expect(() => handler.loadMovies(), throwsA(isA<Exception>()));
  });

  test('loadMovies imageBaseUrl from settings', () async {
    final mip = MockMovieInfoProvider();
    final ds = MockDataSource();
    final ns = MockNotificationService();
    final ws = MockWatchlistService();
    final handler = LoadMoviesHandler(
      datasource: ds,
      moviesProvider: (_) => mip,
      notificationService: ns,
      watchlistService: ws,
    );

    when(() => ds.getSettings()).thenAnswer(
      (_) async => Settings(
        imageBaseUrl: 'imageBaseUrl',
        chatId: null,
        watchlistId: null,
      ),
    );
    when(() => ds.updateMovies(any(), any())).thenAnswer(
      (_) async {},
    );
    when(() => mip.getImageBasePath()).thenAnswer(
      (_) async => 'null',
    );
    when(() => mip.getMovies()).thenAnswer(
      (_) async => [],
    );

    await handler.loadMovies();

    verify(() => ds.updateMovies('imageBaseUrl', [])).called(1);
    verifyNever(() => ns.sendMessage(any(), any()));
    verifyNever(() => ws.getListMoviesIds(any()));
  });

  test('loadMovies', () async {
    final mip = MockMovieInfoProvider();
    final ds = MockDataSource();
    final ns = MockNotificationService();
    final ws = MockWatchlistService();
    final handler = LoadMoviesHandler(
      datasource: ds,
      moviesProvider: (_) => mip,
      notificationService: ns,
      watchlistService: ws,
    );

    when(() => ds.getSettings()).thenAnswer(
      (_) async => Settings(
        imageBaseUrl: null,
        chatId: 'chatId',
        watchlistId: 'watchlistId',
      ),
    );
    when(() => ds.updateMovies(any(), any())).thenAnswer(
      (_) async {},
    );
    when(() => mip.getImageBasePath()).thenAnswer(
      (_) async => 'getImageBasePath',
    );
    final movies = [
      MovieInfo(
        tmdbId: 1,
        imdbId: 'imdbId',
        kinopoiskId: 'kinopoiskId',
        posterPath: 'posterPath',
        overview: 'overview',
        releaseDate: DateTime(2000),
        title: 'title',
        backdropPath: 'backdropPath',
        rating: MovieRating(
          imdbVoteAverage: 1,
          imdbVoteCount: 2,
          kinopoiskVoteAverage: 3,
          kinopoiskVoteCount: 4,
          tmdbVoteCount: 5,
          tmdbVoteAverage: 6,
        ),
        torrentsInfo: [
          MovieTorrentInfo(
            magnetUrl: 'magnetUrl',
            title: 'title',
            size: 1,
            seeders: 2,
            leechers: 3,
            audio: ['audio', 'audio2'],
            date: DateTime(2000),
          ),
        ],
        youtubeTrailerKey: 'youtubeTrailerKey',
        cast: [
          MovieCast(
            character: 'character',
            name: 'name',
            profilePath: 'profilePath',
          ),
        ],
        crew: [],
        productionCountries: ['productionCountries'],
        genres: ['genres'],
      ),
    ];
    when(() => mip.getMovies()).thenAnswer(
      (_) async => movies,
    );
    when(() => ws.getListMoviesIds(any())).thenAnswer((_) async => ['1']);
    when(() => ns.sendMessage(any(), any())).thenAnswer((_) async {});

    await handler.loadMovies();

    verify(() => ds.updateMovies('getImageBasePath', movies)).called(1);
    verify(() => ws.getListMoviesIds('watchlistId')).called(1);
    verify(
      () => ns.sendMessage(
        'chatId',
        '<a href="https://minia68.github.io/index1.html?1">title</a>',
      ),
    ).called(1);
  });
}

class MockDataSource extends Mock implements DataSource {}

class MockMovieInfoProvider extends Mock implements MovieInfoProvider {}

class MockNotificationService extends Mock implements NotificationService {}

class MockWatchlistService extends Mock implements WatchlistService {}
