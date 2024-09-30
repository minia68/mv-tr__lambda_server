import 'package:dio/dio.dart';

// ignore: one_member_abstracts
abstract interface class NotificationService {
  Future<void> sendMessage(String chatId, String message);
}

class TelegramNotificationService implements NotificationService {
  TelegramNotificationService({
    required Dio dio,
    required String botToken,
  })  : _dio = dio,
        _botToken = botToken;

  final Dio _dio;
  final String _botToken;

  @override
  Future<void> sendMessage(String chatId, String message) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.telegram.org/bot$_botToken/sendMessage',
      queryParameters: {
        'chat_id': chatId,//843254883
        'text': message,
        'parse_mode': 'HTML',
      },
    );
    if (!(response.data?['ok'] as bool? ?? false)) {
      throw TelegramNotificationServiceException(
        response.data?['description'] as String? ?? 'no description',
      );
    }
  }
}

class TelegramNotificationServiceException implements Exception {
  TelegramNotificationServiceException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}
