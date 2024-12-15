import 'package:rocket_chat_flutter_client/models/room.dart';
import 'package:rocket_chat_flutter_client/models/subscription_update.dart';

class RoomChange {
  final RoomChangeType changeType;
  final Room room;
  final SubscriptionUpdate subscriptionUpdate;

  RoomChange(this.changeType, this.room, this.subscriptionUpdate);
}

enum RoomChangeType {
  updated,
  added,
  removed,
}

RoomChangeType getRoomChangeType(String changeType) {
  return RoomChangeType.values.firstWhere((e) => e.name == changeType);
}

// switch (changeType) {
//             case RoomChangeType.updated:
//               print('room with id ${value['id']} updated!');

//               // update the room list.
//               _rooms.add(SubscriptionUpdate.fromMap(message));
//               break;
//             case RoomChangeType.added:
//               print('room with id ${value['id']} added!');
//               break;
//             case RoomChangeType.removed:
//               print('room with id ${value['id']} removed!');
//               break;
//           }