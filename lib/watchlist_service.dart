// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';

abstract interface class WatchlistService {
  Future<List<String>> getListMoviesIds(String listId);
}

class TmdbWatchlistService implements WatchlistService {
  TmdbWatchlistService({
    required Dio dio,
    required String tmdbApiKey,
  })  : _dio = dio,
        _tmdbApiKey = tmdbApiKey;

  final Dio _dio;
  final String _tmdbApiKey;

  @override
  Future<List<String>> getListMoviesIds(String listId) async {
    final respone = await _dio.get<Map<String, dynamic>>(
      'https://api.themoviedb.org/3/list/$listId?language=ru-RU&api_key=$_tmdbApiKey',
    );
    return (respone.data?['items'] as List<dynamic>?)
            ?.map((e) => ((e as Map<String, dynamic>)['id'] as int).toString())
            .toList() ??
        [];
  }
}
