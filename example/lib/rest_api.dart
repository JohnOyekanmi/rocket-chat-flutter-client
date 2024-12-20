// import 'package:rocket_chat_flutter_client/models/authentication.dart';
// import 'package:rocket_chat_flutter_client/models/channel.dart';
// import 'package:rocket_chat_flutter_client/models/channel_counters.dart';
// import 'package:rocket_chat_flutter_client/models/channel_messages.dart';
// import 'package:rocket_chat_flutter_client/models/filters/channel_counters_filter.dart';
// import 'package:rocket_chat_flutter_client/models/filters/channel_history_filter.dart';
// import 'package:rocket_chat_flutter_client/models/new/message_new.dart';
// import 'package:rocket_chat_flutter_client/models/response/message_new_response.dart';
// import 'package:rocket_chat_flutter_client/models/subscription.dart';
// import 'package:rocket_chat_flutter_client/models/subscription_update.dart';
// import 'package:rocket_chat_flutter_client/services/authentication_service.dart';
// import 'package:rocket_chat_flutter_client/services/channel_service.dart';
// import 'package:rocket_chat_flutter_client/services/http_service.dart'
//     as rocket_http_service;
// import 'package:rocket_chat_flutter_client/services/message_service.dart';
// import 'package:rocket_chat_flutter_client/services/subscription_service.dart';

// final String serverUrl = "myServerUrl";
// final String username = "myUserName";
// final String password = "myPassword";
// final Channel channel = Channel(id: "myChannelId");

// final rocket_http_service.HttpService rocketHttpService =
//     rocket_http_service.HttpService(Uri.parse(serverUrl));
// final AuthenticationService authenticationService =
//     AuthenticationService(rocketHttpService);
// final ChannelService channelService = ChannelService(rocketHttpService);
// final MessageService messageService = MessageService(rocketHttpService);
// final SubscriptionService subscriptionService =
//     SubscriptionService(rocketHttpService);

// Future main(List<String> args) async {
//   Authentication authentication =
//       await authenticationService.login(username, password);

//   // get all subscription with new messages
//   Subscription subscription =
//       await subscriptionService.getSubscriptions(authentication);
//   List<SubscriptionUpdate> updates =
//       subscription.update!.where((e) => e.alert!).toList();

//   for (SubscriptionUpdate subscriptionUpdate in updates) {
//     print(
//         "${subscriptionUpdate.t == "d" ? "Room" : "Channel"} rid ${subscriptionUpdate.rid} named ${subscriptionUpdate.name} have new messages");
//   }

//   // get channel message counter
//   ChannelCountersFilter filter = ChannelCountersFilter(channel);
//   ChannelCounters counters =
//       await channelService.counters(filter, authentication);
//   print("Channel specified have ${counters.unreads} unread messages");

//   // get channel message list
//   ChannelHistoryFilter channelHistoryFilter =
//       ChannelHistoryFilter(channel, count: 50);
//   ChannelMessages channelMessages =
//       await channelService.history(channelHistoryFilter, authentication);
//   print(
//       "Last message : ${channelMessages.messages!.first.ts} : ${channelMessages.messages!.first.msg}");

//   // send message
//   MessageNew messageNew = MessageNew(roomId: channel.id, message: "my message");
//   MessageNewResponse response =
//       await messageService.sendMessage(messageNew, authentication);
//   print("Message send success : ${response.success}");
// }
