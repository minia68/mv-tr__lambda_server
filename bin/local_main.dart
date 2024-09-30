import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:movie_info_provider/movie_info_provider.dart';

void main(List<String> arguments) async {
  Logger.root.level = Level.ALL;
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

  final p = MovieInfoProvider(
    [
      NnmClubTrackerDatasource(
        baseUrl: 'https://nnmclub.to/forum',
        query: '/tracker.php?f=954&nm=2160p&o=10',
      )
    ],
    //[RutorTrackerDataSource(baseUrl: 'https://rutor.info')],
    DummyRatingDatasource(),
    TmdbDataSource('a7d10d606965aad52faeab22cce70915'),
    //['/search/0/1/000/2/2160p'],
  );
  final m = await p.getMovies();
  print(json.encode(m));
}
