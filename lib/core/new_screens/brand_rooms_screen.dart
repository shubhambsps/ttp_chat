import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/screens/chat/util.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/theme/style.dart';

class BrandRoomsScreen extends StatefulWidget {
  final bool? isSwitchedAccount;

  const BrandRoomsScreen(this.isSwitchedAccount, {Key? key}) : super(key: key);

  @override
  _BrandRoomsScreenState createState() => _BrandRoomsScreenState();
}

class _BrandRoomsScreenState extends State<BrandRoomsScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<List<types.Room>>(
        stream: widget.isSwitchedAccount! ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).rooms() : FirebaseChatCore.instance.rooms(),
        initialData: const [],
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Expanded(child: Center(child: CircularProgressIndicator()));
            default:
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return noRoomWidget();
              }
              return roomsListWidget(snapshot);
          }

        },
      ),
    );
  }

  Widget startChatMessageWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/chat_icons/start_chat.svg',
            width: 34,
            height: 34,
          ),
          const SizedBox(height: 20),
          Text(
            'Connect with the community',
            style: appBarTitleStyle(context).copyWith(fontSize: 22),
          ),
          const SizedBox(height: 12),
          const Text(
            'Thriving communities are made up of vibrant connections. Chat makes it personal, putting you in direct contact with your fans and customers.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
              icon: Icon(
                Icons.add_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              label: Text(
                'Start Your First Chat',
                style: appBarTitleStyle(context).copyWith(fontSize: 14),
              ),
              onPressed: () {
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchUserScreen()));*/
              })
        ],
      ),
    );
  }

  Widget roomsListWidget(AsyncSnapshot<List<types.Room>> snapshot){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.only(top: 17),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: snapshot.data!.where((element) => element.metadata!['other_user_type'] == 'brand').toList().length,
        itemBuilder: (context, index) {
          var brandList = snapshot.data!.where((element) => element.metadata!['other_user_type'] == 'brand').toList();

          return GestureDetector(
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(brandList[index], widget.isSwitchedAccount!),
                ),
              );
            },
            child: Row(
              children: [
                _buildAvatar(brandList[index]),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              brandList[index].name!,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Last message',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '11:30 AM',
                            // DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(widget.chatUsersModel.lastMessageTimeStamp! * 1000)),
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 17);
        },
      ),
    );
  }

  Widget _buildAvatar(types.Room room) {
    var color = Colors.white;

    if (room.type == types.RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
              (u) => u.id != FirebaseAuth.instance.currentUser!.uid,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found
      }
    }

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

  Widget noRoomWidget(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/chat_icons/no_chat_user.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'No result',
            style: appBarTitleStyle(context).copyWith(fontSize: 16),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
