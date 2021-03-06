import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/screens/chat/util.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';

class ChatPage extends StatelessWidget {
  final types.Room selectedChatUser;
  final bool isSwitchedAccount;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  ChatPage(this.selectedChatUser, this.isSwitchedAccount, this.onViewOrderDetailsClick);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => ChatProvider.initialiseAndLoadMessages(
          selectedChatUser, isSwitchedAccount),
      child: _ChatPage(isSwitchedAccount, onViewOrderDetailsClick),
    );
  }
}

class _ChatPage extends StatefulWidget {
  final bool isSwitchedAccount;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  _ChatPage(this.isSwitchedAccount, this.onViewOrderDetailsClick);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage>
    with SingleTickerProviderStateMixin {
  late ChatProvider chatProvider;
  late AnimationController controller;
  late Animation<Offset> offset;
  bool isOk = false;
  String otherUserName = '';

  @override
  void initState() {
    super.initState();

    chatProvider = context.read<ChatProvider>();
    chatProvider.openTheRecorder();
    chatProvider.flutterSoundPlayer.openAudioSession();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    offset = Tween<Offset>(begin: const Offset(-2.0, 0.0), end: Offset.zero)
        .animate(controller);

    updateUnreadMessageStatus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    chatProvider.disposeAudioMessageTimer();
  }

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        titleSpacing: 1,
        title: Row(
          children: [
            /*Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(chatProvider.selectedChatUser.imageUrl))),
            ),*/
            _buildAvatar(chatProvider.selectedChatUser!),
            const SizedBox(
              width: 10,
            ),
            Text(
              chatProvider.selectedChatUser!.name!,
              style: appBarTitleStyle(context),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: SvgPicture.asset(
                'assets/icons/settings_two.svg',
                color: Theme.of(context).primaryColor,
                height: 18,
                width: 18,
              ),
              onPressed: () {}),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: StreamBuilder<types.Room>(
            initialData: chatProvider.selectedChatUser,
            stream: /*widget.isSwitchedAccount
                ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary'))
                    .room(chatProvider.selectedChatUser!.id)
                : */FirebaseChatCore.instance
                    .room(chatProvider.selectedChatUser!.id),
            builder: (context, snapshot) {
              return StreamBuilder<List<types.Message>>(
                initialData: const [],
                stream: /*widget.isSwitchedAccount
                    ? FirebaseChatCore.instanceFor(
                            app: Firebase.app('secondary'))
                        .messages(snapshot.data!)
                    : */FirebaseChatCore.instance.messages(snapshot.data!),
                builder: (context, snapshot) {
                  return Stack(
                    children: [
                      Chat(
                        messages: snapshot.data ?? [],
                        // messages: [],
                        dateFormat: DateFormat('dd MMM'),
                        dateLocale: '',
                        timeFormat: DateFormat('hh:mm a'),
                        isLastPage: false,
                        onEndReached: () async {
                          debugPrint('END');
                        },
                        onEndReachedThreshold: 10.0,
                        onTextChanged: (String value) {},
                        isAttachmentUploading:
                            chatProvider.isAttachmentUploading,
                        onAttachmentPressed: _handleAttachmentPressed,
                        onVoiceMessagePressed: _handleVoiceMessagePressed,
                        onMessageTap: chatProvider.handleFBMessageTap,
                        onPreviewDataFetched:
                            chatProvider.handleFBPreviewDataFetched,
                        onSendPressed: chatProvider.handleFBSendPressed,
                        user: types.User(
                          id: /*widget.isSwitchedAccount
                              ? FirebaseChatCore.instanceFor(
                                          app: Firebase.app('secondary'))
                                      .firebaseUser
                                      .uid
                              : */FirebaseChatCore.instance.firebaseUser.uid,
                        ),
                        buildCustomMessage: (message) {
                          print('CUSTOM MESSAGE METADATA: ${message.createdAt}');
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(2),
                              color: ThemeUtils.defaultAppThemeData.scaffoldBackgroundColor
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor),
                                    child: Text(
                                      getOrderStatus(message.metadata!['status']),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Divider(color: Colors.grey[300]!),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Expanded    (
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order ${message.metadata!['id']}',
                                              style: TextStyle(
                                                  color: Theme.of(context).primaryColor,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(
                                              height: 6.0,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  getOrderDate(message.createdAt!),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  softWrap: true,
                                                ),
                                                Text(
                                                  ' \u2022 ${message.metadata!['total_items']} items',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  softWrap: true,
                                                ),
                                                Text(
                                                  ' \u2022 \$${message.metadata!['total_price_db']}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  softWrap: true,
                                                ),
                                                Text(
                                                  ' \u2022 ${getOrderType(message.metadata!['type'])}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 26.0,
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                widget.onViewOrderDetailsClick!(
                                                  message.metadata!['id'],
                                                  message.metadata!['message_type'],
                                                  message.metadata!['link'] ?? ''
                                                );
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey[300]!)),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(vertical: 12),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/icon/order_details.svg',
                                                        width: 18,
                                                        height: 18,
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        'View Order Details',
                                                        style: TextStyle(
                                                            color: Theme.of(context).primaryColor,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onMessageLongPress: (message){},
                        showUserAvatars: false,
                        theme: DefaultChatTheme(
                          messageBorderRadius: 0.0,
                          backgroundColor: ThemeUtils
                              .defaultAppThemeData.scaffoldBackgroundColor,
                          primaryColor: Theme.of(context).colorScheme.secondary,
                          secondaryColor: Theme.of(context).primaryColor,
                          inputTextColor: Theme.of(context).primaryColor,
                          sentMessageBodyTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                          sentMessageCaptionTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                          sentMessageLinkTitleTextStyle:
                              const TextStyle(color: Colors.white),
                          sentMessageLinkDescriptionTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                          receivedMessageBodyTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                          receivedMessageCaptionTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                          receivedMessageLinkTitleTextStyle:
                              const TextStyle(color: Colors.white),
                          receivedMessageLinkDescriptionTextStyle:
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                          sentMessageDocumentIconColor: Colors.white,
                          receivedMessageDocumentIconColor: Colors.white,
                        ),
                        emptyState: emptyMessageState(),
                        customDateHeaderText: (DateTime dateTime) {
                          return DateFormat('dd MMM | hh:mm a')
                              .format(dateTime)
                              .toUpperCase();
                        },
                      ),
                      if (isOk)
                        SlideTransition(
                          position: offset,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 88,
                              padding: EdgeInsets.fromLTRB(
                                0, //24 + _query.padding.left,
                                20,
                                0, //24 + _query.padding.right,
                                20 +
                                    MediaQuery.of(context).viewInsets.bottom +
                                    MediaQuery.of(context).padding.bottom,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, 1),
                                    color: const Color(0xFF000000)
                                        .withOpacity(.15),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: SvgPicture.asset(
                                      'assets/icons/delete.svg',
                                      color: Colors.white,
                                      width: 18,
                                      height: 18,
                                    ),
                                    onPressed: () {
                                      chatProvider.stopWaveFormAnimation();
                                      controller.reverse();
                                      chatProvider.removeRecordedVoiceMessage();

                                      /*if (chatProvider.voiceMessageFile != null) {
                                              if (chatProvider
                                                  .isRecordedVoiceMessageFilePlaying) {
                                                chatProvider
                                                    .stopVoiceMessageAnimation();
                                              } else {
                                                chatProvider
                                                    .playVoiceMessageAnimation();
                                              }
                                            }*/
                                    },
                                  ),
                                  /*Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: chatProvider.controller,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: chatProvider.waveFormList
                                              .map((e) {
                                            return SlideTransition(
                                              position: offsetTwo,
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    right: 3),
                                                width: 3,
                                                height: e == 0.0 || e == 1.0
                                                    ? 2.0
                                                    : e,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.white),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),*/
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: chatProvider.controller,
                                        child: AnimatedList(
                                          key: chatProvider.waveFormListKey,
                                          initialItemCount:
                                              chatProvider.waveFormList.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemBuilder:
                                              (context, index, animation) {
                                            return SlideTransition(
                                              position: CurvedAnimation(
                                                curve: Curves.easeOut,
                                                parent: animation,
                                              ).drive((Tween<Offset>(
                                                begin: const Offset(-1, 0),
                                                end: const Offset(0, 0),
                                              ))),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 3),
                                                    child: Container(
                                                      width: 3,
                                                      height: chatProvider.waveFormList[
                                                                      index] ==
                                                                  0.0 ||
                                                              chatProvider.waveFormList[
                                                                      index] ==
                                                                  1.0
                                                          ? 2.0
                                                          : chatProvider
                                                                  .waveFormList[
                                                              index],
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: SvgPicture.asset(
                                      'assets/icons/send.svg',
                                      color: Colors.white,
                                      width: 18,
                                      height: 18,
                                    ),
                                    onPressed: () {
                                      chatProvider.stopRecording();
                                      controller.reverse();
                                      chatProvider.stopWaveFormAnimation();
                                      // chatProvider.handleSendVoiceMessagePressed();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(types.Room user, [double radius = 20]) {
    final color = getRoomAvatarNameColor(user);
    final hasImage = user.imageUrl != null;
    final name = getRoomName(user);

    return CircleAvatar(
      backgroundColor: color,
      backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
      radius: radius,
      child: !hasImage
          ? Text(
              name.isEmpty ? '' : name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
          : null,
    );
  }

  _handleVoiceMessagePressed() {
    // FocusScope.of(context).requestFocus(new FocusNode());
    // chatProvider.handleVoiceMessageSelection(context);

    setState(() {
      isOk = true;
    });
    controller.forward();
    chatProvider.startRecording();
    chatProvider.startWaveFormAnimation();
  }

  void _handleAttachmentPressed() {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.grey.withOpacity(.75),
      elevation: 20,
      builder: (BuildContext context) {
        return Wrap(children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20)),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ListItem(
                      leading: SvgPicture.asset(
                        'assets/icons/photo.svg',
                        height: 18,
                        width: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Upload a photo'),
                      onTap: () {
                        Navigator.pop(context);
                        chatProvider.handleFBImageSelection();
                      },
                    ),
                    /*_ListItem(
                      leading: SvgPicture.asset(
                        'assets/icon/file.svg',
                        height: 18,
                        width: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text('Upload a file'),
                      onTap: () {
                        Navigator.pop(context);
                        chatProvider.handleFBFileSelection();
                      },
                    ),*/
                    // Divider(),
                    const SizedBox(height: 50),
                  ],
                ),
              ],
            ),
          ),
        ]);
      },
    );
  }

  Widget emptyMessageState() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Text(
            'You\'re about to chat up...',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 30),
          _buildAvatar(chatProvider.selectedChatUser!, 50),
          /*Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(chatProvider.otherUser.imageUrl))),
          ),*/
          const SizedBox(height: 14),
          Text(
            chatProvider.selectedChatUser!.name!,
            style: appBarTitleStyle(context),
          ),
          const SizedBox(height: 4),
          Text(
            '@${chatProvider.selectedChatUser!.id}',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text(
                "View Profile",
                style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              onPressed: () {}),
        ],
      ),
    );
  }

  String getOrderStatus(String status){
    switch (status){
      case 'paid':
        return 'PAID';
      case 'checked_out':
        return 'CHECKED OUT';
      case 'failed':
        return 'FAILED';
      case 'rejected':
        return 'REJECTED';
      case 'accepted':
        return 'ACCEPTED';
      case 'scheduled':
        return 'SCHEDULED';
      case 'pending_completion':
        return 'PENDING COMPLETION';
      case 'completed':
        return 'COMPLETED';
      case 'dispute':
        return 'DISPUTE';
      default:
        return '';
    }
  }

  String getOrderType(String orderType){
    switch (orderType){
      case 'pick_up':
        return 'Take Away';
      case 'take_away':
        return 'Take Away';
      case 'dine_in':
        return 'Dine In';
      case 'delivery':
        return 'Delivery';
      default:
        return '';
    }
  }

  String getOrderDate(int orderDate){
    DateTime date = DateTime.fromMillisecondsSinceEpoch(orderDate);

    if(date == DateTime.now()){
      return 'Today';
    }
    else if(date.isBefore(DateTime.now())){
      return DateFormat('dd MMM').format(date);
    }
    else{
      return '';
    }
  }

  void updateUnreadMessageStatus() async{
    try{
      final collection = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(chatProvider.selectedChatUser!.id)
          .collection('messages')
          .where('authorId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // .where('status', isEqualTo: 'sent')


      for(QueryDocumentSnapshot<Map<String, dynamic>> singleMessage in collection.docs){
        FirebaseFirestore.instance
            .collection('rooms')
            .doc(chatProvider.selectedChatUser!.id)
            .collection('messages')
            .doc(singleMessage.id)
            .update({'status': 'delivered'});
      }
    }
    catch (e, s){
      print('UPDATE UNREAD MESSAGE STATUS ERROR CAUGHT: $e\n$s');
    }
  }
}

class AttachmentSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ListItem(
                leading: Image.asset(
                  'assets/icon/dine_in_tab_icon.png',
                  height: 20,
                  width: 20,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Upload a photo'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().handleImageSelection();
                },
              ),
              _ListItem(
                leading: Image.asset(
                  'assets/icon/takeaway_tab_icon.png',
                  height: 20,
                  width: 20,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Upload a file'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().handleFileSelection();
                },
              ),
              _ListItem(
                leading: Image.asset(
                  'assets/icon/delivery_tab_icon.png',
                  height: 20,
                  width: 20,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Upload a voice message'),
                showDivider: true,
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ChatProvider>()
                      .handleVoiceMessageSelection(context);
                },
              ),
              // Divider(),
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Widget? leading;
  final Text? title;
  final Function()? onTap;
  final bool? showDivider;

  const _ListItem({
    Key? key,
    this.leading,
    this.title,
    this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  TextStyle _titleTextStyle(ThemeData theme) {
    return theme.textTheme.bodyText2!.copyWith(
      fontWeight: FontWeight.w600,
      color: onTap != null ? theme.primaryColor : theme.disabledColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    TextStyle titleTextStyle = _titleTextStyle(theme);
    final Widget titleText = AnimatedDefaultTextStyle(
      style: titleTextStyle,
      duration: kThemeChangeDuration,
      child: title ?? Container(),
    );
    return GestureDetector(
      onTap: onTap!,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: leading,
                ),
                const SizedBox(width: 20),
                titleText,
              ],
            ),
          ),
          showDivider! ? const Divider(indent: 50, endIndent: 20) : Container(),
        ],
      ),
    );
  }
}

class VisualComponent extends StatefulWidget {
  final int? duration;
  final Color? color;

  VisualComponent({this.duration, this.color});

  @override
  _VisualComponentState createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration!), vsync: this);
    final curvedAnimation = CurvedAnimation(
        parent: animationController, curve: Curves.easeInOutCubic);

    animation = Tween<double>(begin: 5, end: 100).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5)),
      height: animation.value,
    );
  }
}

class MusicVisualizer extends StatelessWidget {
  List<Color> colors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.yellowAccent
  ];
  List<int> duration = [900, 700, 600, 800, 500];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
            16,
            (index) => VisualComponent(
                  duration: duration[index % 5],
                  color: colors[index % 4],
                )),
      ),
    );
  }
}
