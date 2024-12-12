import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rocket_chat_flutter_client/exceptions/exception.dart';
import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/new/token_new.dart';
import 'package:rocket_chat_flutter_client/models/response/token_new_response.dart';
import 'package:rocket_chat_flutter_client/services/http_service.dart';

class PushService {
  final HttpService _httpService;

  const PushService(this._httpService);

  Future<TokenNewResponse> create(
      TokenNew tokenNew, Authentication authentication) async {
    http.Response response = await _httpService.post(
      '/api/v1/push.token',
      jsonEncode(tokenNew.toMap()),
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return TokenNewResponse.fromMap(jsonDecode(response.body));
      } else {
        return TokenNewResponse();
      }
    }
    throw RocketChatException(response.body);
  }
}