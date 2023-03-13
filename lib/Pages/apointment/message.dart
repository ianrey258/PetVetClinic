import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';

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
  @override
  initState() {
    super.initState();
    setState(() {
      for (int i = 0; i < 10; i++) {
        text.add(TextEditingController());
      }
    });
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
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: ListView(
            reverse: true,
          ),
        ),
        bottomSheet: Container(
          height:50,
          width: double.infinity,
        ),
      ),
    );
  }
}
