import 'dart:io';

import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:aws_lambda_dart_runtime_ns/aws_lambda_dart_runtime_ns.dart';
import 'package:datasource/datasource.dart';
import 'package:domain/src/settings.dart';
import 'package:lambda_server/load_movies_handler.dart';
import 'package:logging/logging.dart';
import 'package:movie_info_provider/movie_info_provider.dart';

void main(List<String> arguments) async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
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
        tmdbApiKey: Platform.environment['TMDB_API_KEY'],
        ds: DynamodbDataSource(db),
        moviesProvider: (settings, tmdbApiKey) => MovieInfoProvider(
          settings.trackerSettings.map<TrackerDataSource>((e) {
            switch (e.trackerType) {
              case TrackerType.rutor:
                return RutorTrackerDataSource(baseUrl: e.trackerUrl);
              case TrackerType.nnmclub:
                return NnmClubTrackerDatasource(baseUrl: e.trackerUrl);
            }
          }).toList(),
          DummyRatingDatasource(),
          TmdbDataSource(tmdbApiKey),
          settings.trackerSettings.map((e) => e.trackerRequest).toList(),
        ),
      );
      await handler.loadMovies();
      db.close();
      return InvocationResult(requestId: ctx.requestId);
    },
  );
  await invokeAwsLambdaRuntime([handler]);
}
