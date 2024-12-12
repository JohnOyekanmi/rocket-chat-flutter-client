import 'dart:async';
import 'dart:io';

import 'package:rocket_chat_flutter_client/models/authentication.dart';
import 'package:rocket_chat_flutter_client/models/media_metadata.dart';
import 'package:rocket_chat_flutter_client/models/message.dart';
import 'package:rocket_chat_flutter_client/models/message_attachment.dart';
import 'package:rocket_chat_flutter_client/models/room.dart';
import 'package:rocket_chat_flutter_client/models/room_change.dart';
import 'package:rocket_chat_flutter_client/models/subscription_update.dart';
import 'package:rocket_chat_flutter_client/models/typing.dart';
import 'package:rocket_chat_flutter_client/models/user.dart';
import 'package:rocket_chat_flutter_client/services/authentication_service.dart';
import 'package:rocket_chat_flutter_client/services/http_service.dart';
import 'package:rocket_chat_flutter_client/services/message_service.dart';
import 'package:rocket_chat_flutter_client/web_socket/web_socket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const int retryAfter = 3;

class RocketChatFlutterClient {
  final String serverUrl;
  final String webSocketUrl;
  final String authToken;
  final String userId;

  RocketChatFlutterClient({
    required this.serverUrl,
    required this.webSocketUrl,
    required this.authToken,
    required this.userId,
  });

  Authentication? auth;
  late AuthenticationService authService;
  late MessageService messageService;
  late WebSocketChannel webSocketChannel;
  final WebSocketService webSocketService = WebSocketService();
  final Map<String, StreamController<List<Message>>> _roomMessages = {};
  final Map<String, StreamController<Typing>> _roomTypings = {};
  final StreamController<RoomChange> _rooms = StreamController();

  bool get _authObjectCreated => auth != null && auth!.data?.me != null;

  // Add these new properties for reconnection handling
  bool _isConnected = false;
  Timer? _reconnectTimer;
  static const int _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;
  
  // Add reconnection method
  Future<void> _reconnect() async {
    if (_isConnected || _reconnectAttempts >= _maxReconnectAttempts) return;

    try {
      _reconnectAttempts++;
      print('Attempting to reconnect (${_reconnectAttempts}/$_maxReconnectAttempts)...');
      
      // connect to the websocket.
      webSocketChannel = webSocketService.connectToWebSocket(webSocketUrl, auth!);
      
      // subscribe to the user.
      // for :rooms-changed
      //     :message
      //     :notification
      webSocketService.streamNotifyUser(webSocketChannel, auth!.data!.me!);
      
      // listen to the websocket messages.
      webSocketChannel.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error, stackTrace) => _handleWebSocketError(error, stackTrace),
        onDone: () => _handleWebSocketDone(),
        cancelOnError: false,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      
      print('Successfully reconnected to WebSocket');
    } on Exception catch (e, s) {
      _handleError('reconnection', e, s);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectTimer = Timer(
        Duration(seconds: retryAfter * _reconnectAttempts), 
        _reconnect
      );
    }
  }

  Future<void> _createAuthObject() async {
    try {
      // create a fake authentication object.
      final _fakeAuth = Authentication.fromMap({
        'data': {
          'authToken': authToken,
          'userId': userId,
        }
      });

      // fetch user data.
      final User me = await authService.me(_fakeAuth);
      // copy the fake authentication object with the user data
      // and set the status to 'success' to yield a valid authentication object.
      auth = _fakeAuth.copyWith(me: me, status: 'success');
    } on Exception catch (e, s) {
      print('Error creating auth object: $e');
      print('Stack trace: $s');

      // retry the operation after [retryAfter] typically 3 seconds.
      Future.delayed(const Duration(seconds: retryAfter), () {
        init();
      });
    }
  }

  /// Initialize the client.
  /// This method will create the authentication object and connect to the websocket.
  /// It will also subscribe to the user and listen to the websocket messages.
  /// If the operation fails, it will retry the operation after [retryAfter] typically 3 seconds.
  /// If the operation fails after [maxReconnectAttempts] attempts, it will stop retrying.
  ///
  /// Typically called in the main function or initState of a StatefulWidget.
  init() async {

    authService = AuthenticationService(HttpService(Uri.parse(serverUrl)));
    messageService = MessageService(HttpService(Uri.parse(serverUrl)));
    // create the authentication object.
    // this will retry the operation after [retryAfter] typically 3 seconds
    // if the operation fails.
    await _createAuthObject();

    // check if the authentication object was created successfully.
    if (!_authObjectCreated) {
      return;
    }

    try {
      // connect to the websocket.
      webSocketChannel = webSocketService.connectToWebSocket(webSocketUrl, auth!);

      // subscribe to the user.
      // for :rooms-changed
      //     :message
      //     :notification
      webSocketService.streamNotifyUser(webSocketChannel, auth!.data!.me!);

      // listen to the websocket messages.
      webSocketChannel.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error, stackTrace) => _handleWebSocketError(error, stackTrace),
        onDone: () => _handleWebSocketDone(),
        cancelOnError: false,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
    } on Exception catch (e, s) {
      _handleError('initialization', e, s);
      _scheduleReconnect();
    }
  }

  void _handleError(String operation, Exception e, StackTrace s) {
    print('Error during $operation: $e');
    print('Stack trace: $s');
  }

  void _handleWebSocketError(Object error, StackTrace stackTrace) {
    _isConnected = false;
    print('WebSocket error: $error');
    print('Stack trace: $stackTrace');
    _scheduleReconnect();
  }

  void _handleWebSocketDone() {
    print('WebSocket connection closed!');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    try {
      print('WebSocket message: ${message['msg']}');

      // handle keep alive messages.
      if (message['msg'] == 'ping') {
        print('Keep alive!');
        webSocketService.sendPong(webSocketChannel);
      }

      // // handle subscription messages.
      // if (message['msg'] == 'sub') {
      //   print('Subscription message: ${message['name']}');
      // }

      if (message['msg'] == 'changed') {
        //handle changes and updates in the room.

        // STREAM-NOTIFY-USER
        if (message['collection'] == 'stream-notify-user') {
          print('collection: is ${message['collection']}');

          // ---> rooms list changes.
          if (message['fields']['eventName'].endsWith('rooms-changed')) {
            print('rooms list change detected!');

            final changeType = getRoomChangeType(message['fields']['args'][0]);
            final value = message['fields']['args'][1];

            final roomChange = RoomChange(
              changeType,
              SubscriptionUpdate.fromMap(value),
            );

            _rooms.add(roomChange);
          }
        }

        // STREAM-NOTIFY-ROOM
        if (message['collection'] == 'stream-notify-room') {
          print('collection: is ${message['collection']}');

          // ---> typing
          if (message['fields']['eventName'].endsWith('typing')) {
            print('typing detected!');

            // extract the room id from the event name.
            final roomId = message['fields']['eventName'].split('/')[0];
            final value = message['fields']['args'];

            _roomTypings[roomId]?.add(Typing.fromList(value));
          }
        }

        // STREAM-ROOM-MESSAGES
        if (message['collection'] == 'stream-room-messages') {
          print('collection: is ${message['collection']}');

          // ---> message
          final roomId = message['fields']['eventName'];
          final List<Map<String, dynamic>> value = message['fields']['args'];

          _roomMessages[roomId]
              ?.add(value.map((m) => Message.fromMap(m)).toList());
        }
      }
    } on Exception catch (e, s) {
      _handleError('_handleWebSocketMessage', e, s);
    }
  }

  /// Get the messages stream for a room.
  Stream<List<Message>> getMessagesStream(String roomId) {
    if (!_roomMessages.containsKey(roomId)) {
      _roomMessages[roomId] = StreamController<List<Message>>();
    }

    return _roomMessages[roomId]!.stream;
  }

  /// Get the typing stream for a room.
  Stream<Typing> getTypingStream(String roomId) {
    if (!_roomTypings.containsKey(roomId)) {
      _roomTypings[roomId] = StreamController<Typing>();
    }

    return _roomTypings[roomId]!.stream;
  }

  /// Get the rooms stream.
  Stream<RoomChange> getRoomsStream() {
    return _rooms.stream;
  }

  /// Send a typing status to the room.
  void sendTyping(Room room, String userId, [bool isTyping = true]) {
    webSocketService.sendUserTyping(webSocketChannel, room, userId, isTyping);
  }

  /// Send a message to the room.
  void sendMessage(Room room, String message) {
    webSocketService.sendMessageOnRoom(message, webSocketChannel, room);
  }

  /// Send a media message to the room.
  ///
  /// The media message is sent as a multipart request to the server.
  /// The server will return the media metadata and the message attachment.
  /// The message attachment is then sent to the room.
  void sendMediaMessage(
    Room room,
    List<File> mediaFiles, [
    String? message,
    MediaType? mediaType,
  ]) async {
    try {
      final mediaMetadataList = <MediaMetadata>[];
      final attachments = <MessageAttachment>[];

      for (var mediaFile in mediaFiles) {
        try {
          // 1. upload the audio file to the server and get the media metadata.
          final mediaMetadata = await messageService.uploadMedia(
            mediaFile,
            message,
            room.id!,
            auth!,
            serverUrl,
          );
          mediaMetadataList.add(mediaMetadata);
        } on Exception catch (e, s) {
          _handleError('media upload', e, s);
          continue; // Skip this file but continue with others
        }
      }

      if (mediaMetadataList.isEmpty) {
        throw Exception('No media files were successfully uploaded');
      }

      for (var mediaMetadata in mediaMetadataList) {
        // 2. create the message attachment.
        final attachment = MessageAttachment(
          audioUrl: mediaType == MediaType.audio ? mediaMetadata.url : null,
          imageUrl: mediaType == MediaType.image ? mediaMetadata.url : null,
          videoUrl: mediaType == MediaType.video ? mediaMetadata.url : null,
        );
        attachments.add(attachment);
      }

      // 3. send the audio message to the room.
      webSocketService.sendMediaMessageOnRoom(
        message,
        attachments,
        webSocketChannel,
        room,
      );
    } on Exception catch (e, s) {
      _handleError('media message sending', e, s);
      rethrow;
    }
  }

  /// Send an audio file to the room.
  void sendAudioMessage(Room room, String? message, List<File> audioFiles) {
    sendMediaMessage(room, audioFiles, message, MediaType.audio);
  }

  /// Send an image file to the room.
  void sendImageMessage(Room room, String? message, List<File> imageFiles) {
    sendMediaMessage(room, imageFiles, message, MediaType.image);
  }

  /// Send a video file to the room.
  void sendVideoMessage(Room room, String? message, List<File> videoFiles) {
    sendMediaMessage(room, videoFiles, message, MediaType.video);
  }

  // void sendPresence(Room room, String userId) {
  //   webSocketService.sendUserPresence(webSocketChannel);
  // }

  // Add cleanup method
  void dispose() {
    _reconnectTimer?.cancel();
    webSocketChannel.sink.close();
    _roomMessages.values.forEach((controller) => controller.close());
    _roomTypings.values.forEach((controller) => controller.close());
    _rooms.close();
  }
}
