import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rocket_chat_flutter_client/exceptions/exception.dart';
import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/new/message_new.dart';
import 'package:rocket_chat_flutter_client/models/response/message_new_response.dart';
import 'package:rocket_chat_flutter_client/services/http_service.dart';

class MessageService {
  final HttpService _httpService;

  const MessageService(this._httpService);

  Future<MessageNewResponse> postMessage(
      MessageNew message, Authentication authentication) async {
    http.Response response = await _httpService.post(
      '/api/v1/chat.postMessage',
      jsonEncode(message.toMap()),
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return MessageNewResponse.fromMap(jsonDecode(response.body));
      } else {
        return MessageNewResponse();
      }
    }
    throw RocketChatException(response.body);
  }
}
