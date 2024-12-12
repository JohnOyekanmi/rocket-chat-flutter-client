import 'dart:convert';

import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/channel.dart';
import 'package:rocket_chat_flutter_client/models/message_attachment.dart';
import 'package:rocket_chat_flutter_client/models/room.dart';
import 'package:rocket_chat_flutter_client/models/user.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel connectToWebSocket(
      String url, Authentication authentication) {
    WebSocketChannel webSocketChannel = IOWebSocketChannel.connect(url);
    _sendConnectRequest(webSocketChannel);
    _sendLoginRequest(webSocketChannel, authentication);
    return webSocketChannel;
  }

  void _sendConnectRequest(WebSocketChannel webSocketChannel) {
    Map msg = {
      "msg": "connect",
      "version": "1",
      "support": ["1", "pre2", "pre1"]
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void _sendLoginRequest(
      WebSocketChannel webSocketChannel, Authentication authentication) {
    Map msg = {
      "msg": "method",
      "method": "login",
      "id": "42",
      "params": [
        {"resume": authentication.data!.authToken}
      ]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendPong(WebSocketChannel webSocketChannel) {
    Map msg = {
      "msg": "pong",
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamNotifyRoom(WebSocketChannel webSocketChannel, Room room) {
    Map msg = {
      "msg": "sub",
      "id": room.id! + "subscription-id",
      "name": "stream-notify-room",
      // params[1] indicates the subscription is persistent and should continue receiving updates.
      "params": ["${room.id!}/rooms-changed", true],
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamNotifyUser(WebSocketChannel webSocketChannel, User user) {
    Map msg = {
      "msg": "sub",
      "id": user.id! + "subscription-id",
      "name": "stream-notify-user",
      // params[1] indicates the subscription is persistent and should continue receiving updates.
      "params": ["${user.id!}/notification", true],
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  // void streamRoomList(WebSocketChannel webSocketChannel, String userId) {
  //   Map msg = {
  //     "msg": "method",
  //     "method": "rooms/get",
  //     "id": "{$userId}/rooms.get",
  //   };

  //   webSocketChannel.sink.add(jsonEncode(msg));
  // }

  void streamNotifyUserSubscribe(WebSocketChannel webSocketChannel, User user) {
    Map msg = {
      "msg": "sub",
      "id": user.id! + "subscription-id",
      "name": "stream-notify-user",
      "params": [user.id! + "/notification", false]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamChannelMessagesSubscribe(
      WebSocketChannel webSocketChannel, Channel channel) {
    Map msg = {
      "msg": "sub",
      "id": channel.id! + "subscription-id",
      "name": "stream-room-messages",
      "params": [channel.id, false]
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamChannelMessagesUnsubscribe(
      WebSocketChannel webSocketChannel, Channel channel) {
    Map msg = {
      "msg": "unsub",
      "id": channel.id! + "subscription-id",
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamRoomMessagesSubscribe(
      WebSocketChannel webSocketChannel, Room room) {
    Map msg = {
      "msg": "sub",
      "id": room.id! + "subscription-id",
      "name": "stream-room-messages",
      "params": [room.id, true]
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamRoomMessagesUnsubscribe(
      WebSocketChannel webSocketChannel, Room room) {
    Map msg = {
      "msg": "unsub",
      "id": room.id! + "subscription-id",
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendMessageOnChannel(
      String message, WebSocketChannel webSocketChannel, Channel channel) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "${channel.id!}/sendMessage",
      "params": [
        {"rid": channel.id, "msg": message}
      ]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendMessageOnRoom(
      String message, WebSocketChannel webSocketChannel, Room room) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "${room.id!}/sendMessage",
      "params": [
        {"rid": room.id, "msg": message}
      ]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendUserPresence(WebSocketChannel webSocketChannel) {
    Map msg = {
      "msg": "method",
      "method": "UserPresence:setDefaultStatus",
      "id": "42",
      "params": ["online"]
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendUserTyping(
      WebSocketChannel webSocketChannel, Room room, String userId,
      [bool isTyping = true]) {
    Map msg = {
      "msg": "method",
      "method": "stream-notify-room",
      "id": "${room.id!}/${userId}/typing",
      "params": [
        "${room.id!}/typing",
        userId,
        isTyping,
      ],
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendMediaMessageOnRoom(
    String? message,
    List<MessageAttachment> attachments,
    WebSocketChannel webSocketChannel,
    Room room,
  ) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "${room.id!}/send-media-message",
      "params": [
        {
          "rid": room.id,
          "msg": message,
          "attachments": attachments.map((e) => e.toMap()).toList(),
        }
      ]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }
}
