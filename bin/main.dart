import 'dart:io';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:aws_lambda_dart_runtime_ns/aws_lambda_dart_runtime_ns.dart';
import 'package:datasource/datasource.dart';
import 'package:dio/dio.dart';
import 'package:domain/src/settings.dart';
import 'package:lambda_server/load_movies_handler.dart';
import 'package:lambda_server/notification_service.dart';
import 'package:lambda_server/watchlist_service.dart';
import 'package:logging/logging.dart';
import 'package:movie_info_provider/movie_info_provider.dart';

final _logger = Logger('WatchlistService');

void main(List<String> arguments) async {
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    if (record.error != null) {
      stderr
        ..writeln('${record.level.name}: ${record.time}: ${record.message}')
        ..writeln(record.error)
        ..writeln(record.stackTrace);
    } else {
      stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
    }
  });

  final tmdbApiKey = Platform.environment['TMDB_API_KEY']!;
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(logPrint: _logger.config));

  final handler = FunctionHandler(
    name: Platform.environment['_HANDLER']!,
    action: (ctx, event) async {
      final db = DynamoDB(
        region: ctx.region,
        credentials: AwsClientCredentials(
          accessKey: ctx.accessKey,
          secretKey: ctx.secretAccessKey,
          sessionToken: ctx.sessionToken,
        ),
      );
      final handler = LoadMoviesHandler(
        datasource: DynamodbDataSource(db),
        moviesProvider: (settings) => MovieInfoProvider(
          settings.trackerSettings.map<TrackerDataSource>((e) {
            switch (e.trackerType) {
              case TrackerType.rutor:
                return RutorTrackerDataSource(
                  baseUrl: e.trackerUrl,
                  query: e.trackerRequest,
                  searchLimit: e.torrentsLimit,
                );
              case TrackerType.nnmclub:
                return NnmClubTrackerDatasource(
                  baseUrl: e.trackerUrl,
                  query: e.trackerRequest,
                  searchLimit: e.torrentsLimit,
                );
            }
          }).toList(),
          KpunRatingDatasource(
            apiKey: Platform.environment['KPUN_API_KEY']!,
            dio: dio,
          ),
          TmdbDataSource(tmdbApiKey),
        ),
        watchlistService: TmdbWatchlistService(
          tmdbApiKey: tmdbApiKey,
          dio: dio,
        ),
        notificationService: TelegramNotificationService(
          botToken: Platform.environment['TELEGRAM_BOT_TOKEN'] ?? '',
          dio: dio,
        ),
      );
      await handler.loadMovies();
      db.close();
      dio.close();
      return InvocationResult(requestId: ctx.requestId);
    },
  );
  await invokeAwsLambdaRuntime([handler]);
}
