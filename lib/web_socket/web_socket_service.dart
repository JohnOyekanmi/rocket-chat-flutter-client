import 'dart:convert';

import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/message_attachment.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  Future<WebSocketChannel> connectToWebSocket(
    String url,
    Authentication authentication,
    void Function(dynamic)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) async {
    WebSocketChannel webSocketChannel =
        WebSocketChannel.connect(Uri.parse('$url/websocket'));
    await webSocketChannel.ready;


    webSocketChannel.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

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
      "id": "login-${DateTime.now().millisecondsSinceEpoch}",
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

  void streamNotifyRoom(WebSocketChannel webSocketChannel, String roomId) {
    Map msg = {
      "msg": "sub",
      "id": roomId + "subscription-id",
      "name": "stream-notify-room",
      // params[1] indicates the subscription is persistent and should continue receiving updates.
      "params": ["${roomId}/rooms-changed", true],
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamNotifyUser(WebSocketChannel webSocketChannel, String userId) {
    Map msg = {
      "msg": "sub",
      "id": userId + "subscription-id",
      "name": "stream-notify-user",
      // params[1] indicates the subscription is persistent and should continue receiving updates.
      "params": ["${userId}/notification", true],
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamNotifyRoomTyping(
      WebSocketChannel webSocketChannel, String roomId) {
    Map msg = {
      "msg": "sub",
      "id": roomId + "typing-subscription-id",
      "name": "stream-notify-room",
      // params[1] indicates the subscription is persistent and should continue receiving updates.
      "params": [roomId + "/typing", true]
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

  void streamNotifyUserSubscribe(
      WebSocketChannel webSocketChannel, String userId) {
    Map msg = {
      "msg": "sub",
      "id": userId + "subscription-id",
      "name": "stream-notify-user",
      "params": [userId + "/notification", false]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamChannelMessagesSubscribe(
      WebSocketChannel webSocketChannel, String channelId) {
    Map msg = {
      "msg": "sub",
      "id": channelId + "subscription-id",
      "name": "stream-room-messages",
      "params": [channelId, false]
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamChannelMessagesUnsubscribe(
      WebSocketChannel webSocketChannel, String channelId) {
    Map msg = {
      "msg": "unsub",
      "id": channelId + "subscription-id",
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamRoomMessagesSubscribe(
      WebSocketChannel webSocketChannel, String roomId) {
    Map msg = {
      "msg": "sub",
      "id": roomId + "subscription-id",
      "name": "stream-room-messages",
      "params": [roomId, true]
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void streamRoomMessagesUnsubscribe(
      WebSocketChannel webSocketChannel, String roomId) {
    Map msg = {
      "msg": "unsub",
      "id": roomId + "subscription-id",
    };
    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendMessageOnChannel(
      String message, WebSocketChannel webSocketChannel, String channelId) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "${channelId}/sendMessage",
      "params": [
        {"rid": channelId, "msg": message}
      ]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }

  void sendMessageOnRoom(
      String message, WebSocketChannel webSocketChannel, String roomId) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "${roomId}/sendMessage",
      "params": [
        {"rid": roomId, "msg": message}
      ]
    };

    print('[WEBSOCKET]:sending message to room $roomId: $message');

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
      WebSocketChannel webSocketChannel, String roomId, String userId,
      [bool isTyping = true]) {
    Map msg = {
      "msg": "method",
      "method": "stream-notify-room",
      "id": "${roomId}/${userId}/typing",
      "params": [
        "${roomId}/typing",
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
    String roomId,
  ) {
    Map msg = {
      "msg": "method",
      "method": "sendMessage",
      "id": "${roomId}/send-media-message",
      "params": [
        {
          "rid": roomId,
          "msg": message,
          "attachments": attachments.map((e) => e.toMap()).toList(),
        }
      ]
    };

    webSocketChannel.sink.add(jsonEncode(msg));
  }
}
