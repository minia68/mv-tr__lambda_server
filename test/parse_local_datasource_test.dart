// import 'dart:convert';
// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:domain/domain.dart';
// import 'package:lambda_server/parse_local_datasource.dart';
// import 'package:test/test.dart';

// void main() {
//   late Dio dio;
//   final basePath = 'parse/';

//   setUpAll(() async {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: 'http://localhost:1337/',
//         contentType: 'application/json',
//         headers: {
//           'X-Parse-Application-Id': 'appId',
//           'X-Parse-Master-Key': 'masterKey',
//         },
//       ),
//     );
// //    dio.interceptors.add(LogInterceptor(
// //      responseBody: true,
// //      requestBody: true,
// //    ));
//     final schema = json.decode(
//       (await getProjectFile('script/db_schema.json')).readAsStringSync(),
//     ) as List;
//     for (final classSchema in schema) {
//       await dio.post<String>(
//         'parse/schemas/${classSchema['className']}',
//         data: classSchema,
//       );
//     }
//   });

//   tearDownAll(() {
//     dio.close(force: true);
//   });

//   Future<void> _testConfig(
//       List<MovieInfo> movieInfo, String imageBsePath) async {
//     final response =
//         await dio.get<Map<String, dynamic>>('${basePath}classes/config');
//     final jsonResponse = response.data!['results'] as List;
//     expect(jsonResponse.length, 1);
//     final config = jsonResponse[0] as Map<String, dynamic>;
//     expect(config['imageBasePath'], imageBsePath);
//     expect(config['topSeedersFhdMovies'], isNotNull);
//     final fileResponse = await dio.get<Map<String, dynamic>>(
//       config['topSeedersFhdMovies']['url'] as String,
//     );
//     expect(
//       fileResponse.data!['results'],
//       movieInfo.map((e) => e.toJson()).toList(),
//     );
//   }

//   test('updateData', () async {
//     final ds = ParseLocalDataSource(dio, basePath: basePath);
//     final mi1 = MovieInfo(
//       overview: 'overview1',
//       torrentsInfo: [],
//       imdbId: 'imdbId1',
//       title: 'title1',
//       cast: [],
//       crew: [],
//       genres: [],
//       kinopoiskId: '',
//       productionCountries: [],
//       rating: MovieRating(
//         tmdbVoteCount: 0,
//         tmdbVoteAverage: 0,
//         imdbVoteAverage: 0,
//         imdbVoteCount: 0,
//         kinopoiskVoteAverage: 0,
//         kinopoiskVoteCount: 0,
//       ),
//       tmdbId: 0,
//       posterPath: null,
//       backdropPath: null,
//       releaseDate: null,
//       youtubeTrailerKey: null,
//     );
//     await ds.updateData('testPath', [mi1]);
//     await _testConfig([mi1], 'testPath');

//     final mi2 = MovieInfo(
//       overview: 'overview12',
//       torrentsInfo: [],
//       imdbId: 'imdbId12',
//       title: 'title12',
//       cast: [],
//       crew: [],
//       genres: [],
//       kinopoiskId: '',
//       productionCountries: [],
//       rating: MovieRating(
//         tmdbVoteCount: 0,
//         tmdbVoteAverage: 0,
//         imdbVoteAverage: 0,
//         imdbVoteCount: 0,
//         kinopoiskVoteAverage: 0,
//         kinopoiskVoteCount: 0,
//       ),
//       tmdbId: 0,
//       posterPath: null,
//       backdropPath: null,
//       releaseDate: null,
//       youtubeTrailerKey: null,
//     );
//     await ds.updateData('testPath1', [mi2]);
//     await _testConfig([mi2], 'testPath1');
//   });
// }

// //https://stackoverflow.com/questions/58592859/reading-a-resource-from-a-file-in-a-flutter-test
// Future<File> getProjectFile(String path) async {
//   var dir = Directory.current;
//   while (
//       !dir.listSync().any((entity) => entity.path.endsWith('pubspec.yaml'))) {
//     dir = dir.parent;
//   }
//   return File('${dir.path}/$path');
// }
