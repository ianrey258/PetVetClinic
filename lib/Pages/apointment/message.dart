import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Controller/MessageController.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Model/messageModel.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Services/firebase_messaging.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';

class Message extends StatefulWidget {
  final UserModel? data;
  const Message({Key? key,this.data}) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final ScrollController _sc = ScrollController();
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  UserModel? user;
  ClinicModel? clinic;
  MessageIdModel? message_id;
  @override
  initState() {
    super.initState();
    setState(() {
      for (int i = 0; i < 10; i++) {
        text.add(TextEditingController());
      }
    });
    initLoadData();
  }

  initLoadData() async {
    String clinic_id = await DataStorage.getData('id');
    ClinicModel _clinic = await ClinicController.getClinic(clinic_id);
    MessageIdModel _message_id = await MessageController.getGroupId([_clinic.id??"",user?.id??""]);
    if(_message_id.id == null){
      _message_id.id = null;
      _message_id.users_id = [_clinic.id??"",user?.id??""];
      _message_id = await MessageController.setGroupId(_message_id);
    }
    setState(() {
      clinic = _clinic;
      message_id = _message_id;
    });
  }

  sendMessage() async {
    if(text[0].text != ''){
      MessageModel message = MessageModel('', clinic?.id, text[0].text, 'text', DateTime.now().millisecondsSinceEpoch.toString());
      await MessageController.sendMessage(message_id?.id??"", message);
      FirebaseMessagingService.sendMessageNotification(notification_type[0], "Doc ${await DataStorage.getData('username')}", 'Message', text[0].text, user!.fcm_tokens!,clinic!.toMap());
      _sc.animateTo(0,duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    text[0].clear();
  }


  Widget messageInput() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: (){},
              icon: const Icon(
                Icons.camera_alt,
                size: 25,
              ),
              color: text1Color,
            ),
          ),
          Flexible(
            child: TextField(
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              controller: text[0],
              textAlignVertical: TextAlignVertical.bottom,
              expands: true,
              maxLines: null,
              style: TextStyle(color: text1Color),
              decoration: InputDecoration(
                hintText: 'write here...',
              ),
              onSubmitted: (value) {
                sendMessage();
              },
            )
          ),
          Container(
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: () {
                sendMessage();
              },
              icon: const Icon(Icons.send_rounded),
              color: text1Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget messageContainer(snapshot) {
    MessageModel data = MessageModel.fromMap(jsonDecode(jsonEncode(snapshot)));
    print(data.user);
    if(data.user != clinic?.id){
      return ListTile(
        contentPadding: EdgeInsets.all(1),
        // leading: Container(
        //   // clipBehavior: Clip.hardEdge,
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(50),
        //     child: user?.profile_img != "" ? ImageLoader.loadImageNetwork(user?.profile_img??"",45.0,45.0) : FaIcon(FontAwesomeIcons.circleUser,size: 45,color: text1Color,),
        //   ),
        // ),
        title: Container(
          margin: EdgeInsets.only(right: 50),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius:BorderRadius.circular(20),
                    color: text5Color 
                  ),
                  child: Text(data.message??"",softWrap: true,style: TextStyle(color: text2Color),overflow: TextOverflow.clip,)
                )
              )
            ],
          ),
        ),
      );
    }else{
      return ListTile(
        contentPadding: EdgeInsets.all(1),
        // trailing: Container(
        //   // clipBehavior: Clip.hardEdge,
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(50),
        //     child: clinic?.clinic_img != "" ? ImageLoader.loadImageNetwork(clinic?.clinic_img??"",45.0,45.0) : FaIcon(FontAwesomeIcons.circleUser,size: 45,color: text1Color,)
        //   ),
        // ),
        title: Container(
        margin: EdgeInsets.only(left: 50),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius:BorderRadius.circular(20),
                    color: alternativeColor 
                  ),
                  child: Text(data.message??"",softWrap: true,style: TextStyle(color: text3Color),overflow: TextOverflow.clip,)
                )
              )
            ],
          ),
        ),
      );
    }
  }

  Widget listMessage() {
    if(message_id == null){
      return const Center(child: CircularProgressIndicator());
    }
    return Flexible(
      child: StreamBuilder(
        stream: MessageController.getMessagesSnapshots(message_id?.id??"", 10),
        builder: (BuildContext context,AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
            List listMessages = snapshot.data.docs;
            if (listMessages.isNotEmpty) {
              return ListView(
                  padding: const EdgeInsets.all(10),
                  reverse: true,
                  controller: _sc,
                  children: listMessages.map((snapshot) => messageContainer(snapshot.data())).toList()
                  // children: []
                );
            } else {
              return const Center(
                child: Text('No messages...'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
       }
      )
   );
 }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    setState(() {
      final data = ModalRoute.of(context)!.settings.arguments as UserModel;
      user = data;
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: text1Color,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(user?.username??"",textAlign: TextAlign.center),
          actions: [
            Center(
              child: IconButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/video_call');
                }, 
                icon: FaIcon(FontAwesomeIcons.video)
              ),
            )
          ],
        ),
        // body: Container(
        //   height: double.infinity,
        //   width: double.infinity,
        //   child: ListView(
        //     reverse: true,
        //   ),
        // ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              listMessage(),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
        bottomSheet: Container(
          height:50,
          width: double.infinity,
          child: messageInput(),
        ),
      ),
    );
  }
}
