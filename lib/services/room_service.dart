import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rocket_chat_flutter_client/exceptions/exception.dart';
import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/filters/room_counters_filter.dart';
import 'package:rocket_chat_flutter_client/models/filters/room_filter.dart';
import 'package:rocket_chat_flutter_client/models/filters/room_history_filter.dart';
import 'package:rocket_chat_flutter_client/models/new/room_new.dart';
import 'package:rocket_chat_flutter_client/models/response/response.dart';
import 'package:rocket_chat_flutter_client/models/response/room_new_response.dart';
import 'package:rocket_chat_flutter_client/models/room.dart';
import 'package:rocket_chat_flutter_client/models/room_counters.dart';
import 'package:rocket_chat_flutter_client/models/room_messages.dart';
import 'package:rocket_chat_flutter_client/services/http_service.dart';

class RoomService {
  final HttpService _httpService;

  const RoomService(this._httpService);

  Future<RoomNewResponse> create(
    RoomNew roomNew,
    Authentication authentication,
  ) async {
    http.Response response = await _httpService.post(
      '/api/v1/im.create',
      jsonEncode(roomNew.toMap()),
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return RoomNewResponse.fromMap(jsonDecode(response.body));
      } else {
        return RoomNewResponse();
      }
    }
    throw RocketChatException(response.body);
  }

  Future<Room> getSingleRoom(
      String roomId, Authentication authentication) async {
    http.Response response = await _httpService.get(
      '/api/v1/rooms.info/?roomId=$roomId',
      authentication,
    );

    if (response.statusCode == 200) {
      return Room.fromMap(jsonDecode(response.body)['room']);
    }

    throw RocketChatException(response.body);
  }

  Future<RoomMessages> messages(
      Room room, Authentication authentication) async {
    http.Response response = await _httpService.getWithFilter(
      '/api/v1/im.messages',
      RoomFilter(room),
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return RoomMessages.fromMap(jsonDecode(response.body));
      } else {
        return RoomMessages();
      }
    }
    throw RocketChatException(response.body);
  }

  Future<bool> markAsRead(Room room, Authentication authentication) async {
    Map<String, String?> body = {"rid": room.id};

    http.Response response = await _httpService.post(
      '/api/v1/subscriptions.read',
      jsonEncode(body),
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return Response.fromMap(jsonDecode(response.body)).success == true;
      } else {
        return false;
      }
    }
    throw RocketChatException(response.body);
  }

  Future<RoomMessages> history(
      RoomHistoryFilter filter, Authentication authentication) async {
    http.Response response = await _httpService.getWithFilter(
      '/api/v1/im.history',
      filter,
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return RoomMessages.fromMap(jsonDecode(response.body));
      } else {
        return RoomMessages();
      }
    }
    throw RocketChatException(response.body);
  }

  Future<RoomCounters> counters(
      RoomCountersFilter filter, Authentication authentication) async {
    http.Response response = await _httpService.getWithFilter(
      '/api/v1/im.counters',
      filter,
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return RoomCounters.fromMap(jsonDecode(response.body));
      } else {
        return RoomCounters();
      }
    }
    throw RocketChatException(response.body);
  }
}
