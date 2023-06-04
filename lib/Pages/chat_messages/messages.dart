import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Controller/MessageController.dart';
import 'package:vetclinicapp/Controller/UserController.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final ScrollController _sc = ScrollController();
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  List<UserModel>? user_chat_list = [];
  bool refresh = false;

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
    user_chat_list = [];
    List _user_chat_list = await MessageController.getListMessages();
    _user_chat_list.forEach((user_id) async { 
      UserModel user = await UserController.getUser(user_id);
      setState(() {  
        user_chat_list!.add(user);
      });
    });
  }

  refreshPage(){
    refresh = !refresh;
  }

  Widget chat_card(UserModel user) {
    return Card(
      elevation: 5,
      child: ListTile(
        // tileColor: apointment?.pet_owner_read_status == 'true' ? text1Color : text7Color,
        style: ListTileStyle.list,
        leading: user.profile_img != "" ? ImageLoader.loadImageNetwork(user.profile_img??"",50.0,50.0) : FaIcon(Icons.store,size: 50),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(user.fullname??"")
          ],
        ),
        subtitle: Text(user.username??''),
        trailing: Container(
          // width: 90,
          child: IconButton(
            icon: FaIcon(Icons.message,size: 35,color: text9Color,),
            onPressed: () => Navigator.pushNamed(context, '/message',arguments: user),
          ),
        ),
        onTap: ()=> Navigator.pushNamed(context, '/message',arguments: user),
      ),
    );   
  }

  List<Widget> chatList(){
    if(user_chat_list!.isEmpty){
      return [Center(child: Text("No Messages"),)];
    }
    return user_chat_list!.map((UserModel data) => chat_card(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: text1Color,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Image.asset(logoImg,fit: BoxFit.contain),
          // leading: Container(),
          actions: [
            IconButton(
              onPressed: (){
                // Navigator.pushNamed(context, "/user_profile");
              }, 
              icon: FaIcon(FontAwesomeIcons.filter)
            )
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: RefreshIndicator(
            onRefresh: ()=>initLoadData(),
            child: ListView(
              children: chatList(),
            ),
          ),
        ),
      ),
    );
  }
}
