import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rocket_chat_flutter_client/exceptions/exception.dart';
import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/filters/room_counters_filter.dart';
import 'package:rocket_chat_flutter_client/models/filters/room_history_filter.dart';
import 'package:rocket_chat_flutter_client/models/new/room_new.dart';
import 'package:rocket_chat_flutter_client/models/response/response.dart';
import 'package:rocket_chat_flutter_client/models/response/room_new_response.dart';
import 'package:rocket_chat_flutter_client/models/room.dart';
import 'package:rocket_chat_flutter_client/models/room_counters.dart';
import 'package:rocket_chat_flutter_client/models/room_messages.dart';
import 'package:rocket_chat_flutter_client/models/subscription_update.dart';
import 'package:rocket_chat_flutter_client/services/http_service.dart';

class RoomService {
  final HttpService _httpService;

  const RoomService(this._httpService);

  Future<List<Room>> getRooms(Authentication authentication) async {
    http.Response response =
        await _httpService.get('/api/v1/rooms.get', authentication);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return List.from(decoded['update'].map((room) => Room.fromMap(room)));
    }

    throw RocketChatException(response.body);
  }

  Future<List<SubscriptionUpdate>> getSubscriptions(
      Authentication authentication) async {
    http.Response response =
        await _httpService.get('/api/v1/subscriptions.get', authentication);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return List.from(decoded['update']
          .map((subscription) => SubscriptionUpdate.fromMap(subscription)));
    }

    throw RocketChatException(response.body);
  }

  Future<RoomNewResponse> create(
    RoomNew roomNew,
    Authentication authentication,
  ) async {
    http.Response response = await _httpService.post(
      '/api/v1/im.create',
      jsonEncode(roomNew.toMap()),
      authentication,
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      print('SERVER-RESPONSE: $decoded');
      return RoomNewResponse.fromMap(decoded);
    }

    throw RocketChatException(response.body);
  }

  Future<bool> delete(String roomId, Authentication authentication) async {
    http.Response response = await _httpService.post(
      '/api/v1/im.delete',
      jsonEncode({"roomId": roomId}),
      authentication,
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      print('SERVER-RESPONSE: $decoded');
      return Response.fromMap(decoded).success == true;
    }

    throw RocketChatException(response.body);
  }

  Future<Room> getSingleRoom(
      String roomId, Authentication authentication) async {
    http.Response response = await _httpService.get(
      '/api/v1/rooms.info/?roomId=$roomId',
      authentication,
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      print('SERVER-RESPONSE: $decoded');
      return Room.fromMap(decoded['room']);
    }

    throw RocketChatException(response.body);
  }

  Future<RoomMessages> messages(
      String roomId, Authentication authentication) async {
    http.Response response = await _httpService.get(
      '/api/v1/im.messages?roomId=$roomId',
      authentication,
    );

    final decoded = jsonDecode(response.body);
    print(decoded);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return RoomMessages.fromMap(decoded);
    }
    throw RocketChatException(response.body);
  }

  Future<bool> markAsRead(String roomId, Authentication authentication) async {
    Map<String, String?> body = {"rid": roomId};

    http.Response response = await _httpService.post(
      '/api/v1/subscriptions.read',
      jsonEncode(body),
      authentication,
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Response.fromMap(decoded).success == true;
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

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return RoomMessages.fromMap(decoded);
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

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return RoomCounters.fromMap(decoded);
    }
    throw RocketChatException(response.body);
  }
}
