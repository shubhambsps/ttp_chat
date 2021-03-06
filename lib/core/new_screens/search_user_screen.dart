import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/core/widgets/triangle_painter.dart';
import 'package:ttp_chat/features/chat/domain/search_user_model.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/models/base_model.dart';
import 'package:ttp_chat/network/api_service.dart';
import 'package:ttp_chat/theme/style.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class SearchUserScreen extends StatefulWidget {
  final String? accessToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const SearchUserScreen({Key? key, this.accessToken, this.onViewOrderDetailsClick}) : super(key: key);

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  List<Brands> brandsList = [];
  List<Users> usersList = [];
  int selectedTabIndex = 0;
  bool documentExists = false;
  Map<String, dynamic> existedRoom = {};
  types.User? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDFBEF).withOpacity(0.2),
          title: Text('Start a new chat',
              style: Theme.of(context).textTheme.headline6),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const SizedBox(height: 17),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: InputSearch(
                      hintText: 'Search a brand, user or mobile',
                      onChanged: (String value) {
                        searchUser(value);
                      }),
                ),
                const SizedBox(height: 20),
                brandsList.isEmpty && usersList.isEmpty
                    ? const Text(
                        'Search for someone on Tabletop',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox(),
                brandsList.isNotEmpty || usersList.isNotEmpty
                    ? _tabs()
                    : const SizedBox(),
                brandsList.isNotEmpty || usersList.isNotEmpty
                    ? selectedTabIndex == 0
                        ? brandsListWidget()
                        : usersListWidget()
                    : const SizedBox(),
                const SizedBox(height: 17),
              ],
            ),
          ),
        ));
  }

  void searchUser(String searchValue) async {
    BaseModel<SearchUserModel> response =
    await GetIt.I<ApiService>().searchUser(widget.accessToken!, searchValue);

    if (response.data != null) {
      setState(() {
        brandsList.clear();
        usersList.clear();
        brandsList.addAll(response.data!.brands!);
        usersList.addAll(response.data!.users!);

        if (brandsList.isEmpty) {
          setState(() {
            selectedTabIndex = 1;
          });
        }

        if (usersList.isEmpty) {
          setState(() {
            selectedTabIndex = 0;
          });
        }
      });
    }
  }

  Widget _tabs() {
    return Column(
      children: [
        const SizedBox(height: 17),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tab(0, 'Brands', brandsList.length),
            _tab(1, 'People', usersList.length),
          ],
        ),
        Container(
          height: 3,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 17),
      ],
    );
  }

  Widget _tab(int index, String title, int count) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: selectedTabIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400]),
                  ),
                  const SizedBox(width: 6),
                  count == 0
                      ? const SizedBox()
                      : Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12, height: 1),
                          ),
                        )
                ],
              ),
              const SizedBox(height: 2),
              selectedTabIndex == index
                  ? CustomPaint(
                      painter: TrianglePainter(
                        strokeColor: Theme.of(context).primaryColor,
                        paintingStyle: PaintingStyle.fill,
                      ),
                      child: const SizedBox(
                        height: 6,
                        width: 12,
                      ),
                    )
                  : const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget brandsListWidget() {
    return brandsList.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: brandsList.length,
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[200]),
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                brandsList[index].name!,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${brandsList[index].username!}',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {

                            bool exists = await checkExist(brandsList[index].username!);

                            if(exists){

                              types.Room selectedRoom = types.Room(
                                  id: existedRoom['id'],
                                  type: types.RoomType.direct,
                                  name: existedRoom['name'],
                                  imageUrl: existedRoom['imageUrl'],
                                  userIds: existedRoom['userIds'],
                                  users: [],
                              );

                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(selectedRoom, false, widget.onViewOrderDetailsClick!),
                                ),
                              );
                            }
                            else{
                              await getUserFromFireStore(brandsList[index].username!);

                              final room = await FirebaseChatCore.instance.createRoom(user!);

                              print('ROOM NAME: ${room.name}');
                              print('ROOM ID: ${room.name}');
                              print('ROOM ID: ${room.userIds}');

                              types.Room selectedRoom = types.Room(
                                  id: room.id,
                                  type: types.RoomType.direct,
                                  name: room.name,
                                  imageUrl: room.imageUrl,
                                  userIds: room.userIds,
                                  users: room.users
                              );

                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(selectedRoom, false, widget.onViewOrderDetailsClick!),
                                ),
                              );
                            }
                          },
                          icon: SvgPicture.asset(
                            'assets/chat_icons/chat.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 17);
            },
          )
        : Container(
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

  Widget usersListWidget() {
    return usersList.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: usersList.length,
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[200]),
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usersList[index].firstName != null &&
                                        usersList[index].lastName != null
                                    ? '${usersList[index].firstName!} ${usersList[index].lastName!}'
                                    : 'Guest',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                usersList[index].email != null
                                    ? usersList[index].email!
                                    : usersList[index].phoneNumber!,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            bool exists = await checkExist(usersList[index].phoneNumber!);

                            print('EXISSTTT: $exists');
                            print('EXISSTTT: $existedRoom');

                            if(exists){

                              types.Room selectedRoom = types.Room(
                                id: existedRoom['id'],
                                type: types.RoomType.direct,
                                name: existedRoom['name'],
                                imageUrl: existedRoom['imageUrl'],
                                userIds: existedRoom['userIds'],
                                users: [],
                              );

                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(selectedRoom, false, widget.onViewOrderDetailsClick!),
                                ),
                              );
                            }
                            else{
                              await getUserFromFireStore(usersList[index].phoneNumber!);

                              final room = await FirebaseChatCore.instance.createRoom(user!);

                              print('ROOM NAME: ${room.name}');
                              print('ROOM ID: ${room.name}');
                              print('ROOM ID: ${room.userIds}');

                              types.Room selectedRoom = types.Room(
                                  id: room.id,
                                  type: types.RoomType.direct,
                                  name: room.name,
                                  imageUrl: room.imageUrl,
                                  userIds: room.userIds,
                                  users: room.users
                              );

                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(selectedRoom, false, widget.onViewOrderDetailsClick!),
                                ),
                              );
                            }
                          },
                          icon: SvgPicture.asset(
                            'assets/chat_icons/chat.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 17);
            },
          )
        : Container(
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

  Future<bool> checkExist(String docId) async {
    
    try{
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .where('userIds', arrayContains: docId)
          .get();

      if(snapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
    catch (e){
      // If any error
      print('CHECK EXISTS ERROR $e');
      return false;
    }
  }

  getUserFromFireStore(String userId) async{

    try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      var data = snapshot.data() as Map<String, dynamic>;

      types.User result = types.User(
        id: snapshot.id,
        firstName: data['firstName'],
        lastName: data['lastName'],
        imageUrl: data['imageUrl'],
      );

      user = result;
    }
    catch (e){
      // If any error
      print('GET USER ERROR $e');
    }

    return user!;
  }
}
