import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import 'package:rocket_chat_flutter_client/exceptions/exception.dart';
import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/media_metadata.dart';
import 'package:rocket_chat_flutter_client/models/new/message_new.dart';
import 'package:rocket_chat_flutter_client/models/response/message_new_response.dart';
import 'package:rocket_chat_flutter_client/services/http_service.dart';

class MessageService {
  final HttpService _httpService;

  const MessageService(this._httpService);

  Future<MessageNewResponse> sendMessage(
      MessageNew message, Authentication authentication) async {
    http.Response response = await _httpService.post(
      '/api/v1/chat.sendMessage',
      jsonEncode({
        'message': message.toMap(),
      }),
      authentication,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty == true) {
      return MessageNewResponse.fromMap(jsonDecode(response.body));
    }

    throw RocketChatException(response.body);
  }

  Future<MediaMetadata> uploadMedia(
    File mediaFile,
    String? message,
    String roomId,
    Authentication authentication,
    String serverUrl,
  ) async {
    final mimeType = lookupMimeType(mediaFile.path);
    final fileName = mediaFile.path.split('/').last;

    // 1. read the media file as bytes
    final bytes = await mediaFile.readAsBytes();

    // 2. create the multipart file
    final multipartFile = await http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
      contentType:
          mimeType != null ? http_parser.MediaType.parse(mimeType) : null,
    );

    // Create the multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(serverUrl + '/api/v1/rooms.upload/' + roomId),
    );

    // add the multipart file to the request
    request.files.add(multipartFile);

    // add the headers to the request
    request.headers.addAll({
      'X-Auth-Token': authentication.data!.authToken!,
      'X-User-Id': authentication.data!.userId!,
      'Content-Type': 'multipart/form-data',
    });

    // Send the request
    final response = await request.send();

    // Process the response
    final responseBody = await response.stream.bytesToString();
    final decodedResponse = jsonDecode(responseBody);
    if (response.statusCode == 200) {
      // Handle the response data
      print('Upload successful!');
      print('Response: $decodedResponse');
      return MediaMetadata.fromMap(decodedResponse['file']);
    }

    throw RocketChatException(decodedResponse);
  }
}
