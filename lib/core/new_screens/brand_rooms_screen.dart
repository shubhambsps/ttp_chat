import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/screens/chat/util.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/theme/style.dart';

class BrandRoomsScreen extends StatefulWidget {
  final bool? isSwitchedAccount;
  final String accessToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const BrandRoomsScreen(this.isSwitchedAccount, this.accessToken, this.onViewOrderDetailsClick, {Key? key}) : super(key: key);

  @override
  _BrandRoomsScreenState createState() => _BrandRoomsScreenState();
}

class _BrandRoomsScreenState extends State<BrandRoomsScreen> {

  late Stream<List<types.Room>> stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(FirebaseAuth.instance.currentUser != null) {
      stream = FirebaseChatCore.instance.rooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<List<types.Room>>(
        stream: stream,
        //stream: /*widget.isSwitchedAccount! ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).rooms() : */FirebaseChatCore.instance.rooms(),
        initialData: const [],
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                print('BRAND STREAM B ERROR: ${snapshot.error}');
              }
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
            onTap: () async {
              var result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(brandList[index], widget.isSwitchedAccount!, widget.onViewOrderDetailsClick),
                ),
              );

              if(result == null){
                setState(() {
                  stream = FirebaseChatCore.instance.rooms();
                });
              }
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
                            getLastMessageWidget(brandList[index].metadata!['last_messages']),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            getLastMessageDateTime(brandList[index].metadata!['last_messages']),
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          ),
                          const SizedBox(height: 6),
                          brandList[index].metadata!['unread_message_count'] != 0
                          ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                            child: Text(
                              brandList[index].metadata!['unread_message_count'].toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1
                              ),
                            ),
                          )
                          : const SizedBox()
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

  Widget getLastMessageWidget(Map<String, dynamic> data){
    String lastMessage = '';

    if(data.isNotEmpty){
      if(data['type'] == 'image'){
        return Row(
          children: [
            Icon(
              Icons.image,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            const Text(
              'Image',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
      else if(data['type'] == 'file'){
        return Row(
          children: [
            Icon(
              Icons.file_present,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            const Text(
              'File',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
      else if(data['type'] == 'voice'){
        return Row(
          children: [
            Icon(
              Icons.mic,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            const Text(
              'Voice message',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
      else if(data['type'] == 'custom'){
        return Row(
          children: [
            SvgPicture.asset(
              'assets/chat_icons/order_history.svg',
              width: 14,
              height: 14,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            const Text(
              'Order',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }
      else if(data['type'] == 'text'){
        return Text(
          data['text'],
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    return const SizedBox();
  }

  String getLastMessageDateTime(Map<String, dynamic> lastMessageData){

    String formattedDate = '';

    if(lastMessageData.isNotEmpty){
      Timestamp timestamp = lastMessageData['createdAt'] as Timestamp;
      DateTime d = timestamp.toDate();
      formattedDate = DateFormat('hh:mm a').format(d);
    }
    return formattedDate;
  }
}
