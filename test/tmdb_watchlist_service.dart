import 'package:dio/dio.dart';
import 'package:lambda_server/watchlist_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  test('getListMoviesIds', () async {
    final dio = MockDio();
    when(
      () => dio.get<Map<String, dynamic>>(
        'https://api.themoviedb.org/3/list/listId?language=ru-RU&api_key=tmdbApiKey',
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        data: {
          'created_by': 'minia',
          'description': '',
          'favorite_count': 0,
          'id': 8427744,
          'iso_639_1': 'en',
          'item_count': 4,
          'items': [
            {
              'backdrop_path': '/pnhUBMJFaJzk9AO3h1akhzj3syu.jpg',
              'id': 889737,
              'title': 'Joker: Folie à Deux',
              'original_title': 'Joker: Folie à Deux',
              'overview':
                  "While struggling with his dual identity, Arthur Fleck not only stumbles upon true love, but also finds the music that's always been inside him.",
              'poster_path': '/4zMTQcQOEygyqtBuRn2zgVgGrY7.jpg',
              'media_type': 'movie',
              'adult': false,
              'original_language': 'en',
              'genre_ids': [18, 80, 53],
              'popularity': 257.768,
              'release_date': '2024-10-01',
              'video': false,
              'vote_average': 7.3,
              'vote_count': 7,
            },
            {
              'backdrop_path': '/7h6TqPB3ESmjuVbxCxAeB1c9OB1.jpg',
              'id': 933260,
              'title': 'The Substance',
              'original_title': 'The Substance',
              'overview':
                  'A fading celebrity decides to use a black market drug, a cell-replicating substance that temporarily creates a younger, better version of herself.',
              'poster_path': '/lqoMzCcZYEFK729d6qzt349fB4o.jpg',
              'media_type': 'movie',
              'adult': false,
              'original_language': 'en',
              'genre_ids': [18, 27, 878],
              'popularity': 818.45,
              'release_date': '2024-09-07',
              'video': false,
              'vote_average': 7.2,
              'vote_count': 137,
            },
            {
              'backdrop_path': '/9SSEUrSqhljBMzRe4aBTh17rUaC.jpg',
              'id': 945961,
              'title': 'Alien: Romulus',
              'original_title': 'Alien: Romulus',
              'overview':
                  'While scavenging the deep ends of a derelict space station, a group of young space colonizers come face to face with the most terrifying life form in the universe.',
              'poster_path': '/b33nnKl1GSFbao4l3fZDDqsMx0F.jpg',
              'media_type': 'movie',
              'adult': false,
              'original_language': 'en',
              'genre_ids': [27, 878, 28],
              'popularity': 547.572,
              'release_date': '2024-08-13',
              'video': false,
              'vote_average': 7.064,
              'vote_count': 1082,
            },
            {
              'backdrop_path': '/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg',
              'id': 533535,
              'title': 'Deadpool & Wolverine',
              'original_title': 'Deadpool & Wolverine',
              'overview':
                  'A listless Wade Wilson toils away in civilian life with his days as the morally flexible mercenary, Deadpool, behind him. But when his homeworld faces an existential threat, Wade must reluctantly suit-up again with an even more reluctant Wolverine.',
              'poster_path': '/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
              'media_type': 'movie',
              'adult': false,
              'original_language': 'en',
              'genre_ids': [28, 35, 878],
              'popularity': 1923.099,
              'release_date': '2024-07-24',
              'video': false,
              'vote_average': 7.7,
              'vote_count': 3152,
            },
          ],
          'name': 'mv-tr',
          'page': 1,
          'poster_path': null,
          'total_pages': 1,
          'total_results': 4,
        },
      ),
    );

    final result =
        await TmdbWatchlistService(dio: dio, tmdbApiKey: 'tmdbApiKey')
            .getListMoviesIds('listId');
    expect(result, ['889737', '933260', '945961', '533535']);
  });
}

class MockDio extends Mock implements Dio {}
