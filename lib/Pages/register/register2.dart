// ignore_for_file: prefer_const_constructors

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Pages/LoadingScreen/LoadingScreen.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';


class Register2 extends StatefulWidget {
  final List<TextEditingController>? text;
  const Register2({super.key,this.text});

  @override
  State<Register2> createState() => _Register2State();
}

class _Register2State extends State<Register2> {
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  int? last_index = 0;
  bool obscure = true;

  @override
  initState() {
    super.initState();
    setState(() {
      for (int i = 0; i < 10; i++) {
        text.add(TextEditingController());
      }
    });
  }

  bool validation(){
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      setState(() {
        text = filterTextEdititor(text);
      });
      return true;
    }
    return false;
  }

  List<TextEditingController> filterTextEdititor(List<TextEditingController> _text){
    return _text.where((TextEditingController element) => element.text.isNotEmpty).toList();
  }

  Widget registerButton(){
    return TextButton.icon(
      icon: Padding(
        padding: EdgeInsets.only(left: 8),
        child: FaIcon(FontAwesomeIcons.arrowRight,color: text1Color, size: 30,),
      ),
      label: Text(""),
      style: buttonStyleA(100, 50, 10, primaryColor),
      onPressed: () async {
        if(text[last_index! + 1].text == ""){
          return CherryToast.error(title: Text("Please Select a Logo.")).show(context); 
        }
        if(text[last_index! + 2].text == ""){
          return CherryToast.error(title: Text("Please Select a Banner.")).show(context); 
        }
        if(!validation()){
          return null; 
        }
        Navigator.pushNamed(context, '/register3',arguments: text);
      },
    );
  }

  Widget addImage(int index,double width,double height){
    return Center(
      child: TextButton(
        onPressed: () async {
          ImagePicker _picker = ImagePicker();
          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
          if(image != null){
            setState(() {
              text[last_index! + index].text = image.path;
            });
          }
        },
        child: text[last_index! + index].text != "" ? ImageLoader.loadImageFile(text[last_index! + index].text,width,height) : FaIcon(Icons.image_search,size: 150,color: text1Color,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    setState(() {
      final data = ModalRoute.of(context)!.settings.arguments as List<TextEditingController>;
      if(data.isNotEmpty && text[0].text == ''){
        text = data + text;
        last_index = data.length - 1;
      }
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.only(left: 20,right: 20),
          height: size.height*.90,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Image.asset(logoImg,fit: BoxFit.contain),
                )
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      SizedBox(
                        height: 35,
                        child:Text(
                          "Logo and Banner",
                          style: TextStyle(
                            fontSize: 30
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        child:Text(
                          "Select your best clinic identity image.",
                          style: TextStyle(
                            fontSize: 15
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ),
              Expanded(
                flex: 7,
                child: Form(
                  key: _key,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Center(
                          child: Text('Clinic Logo',style: TextStyle(fontSize: 20),),
                        ),
                        addImage(1,150,150),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text('Clinic Banner',style: TextStyle(fontSize: 20),),
                        ),
                        addImage(2,250,150),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 5),
                        //   child: loginTextButton(),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30,bottom: 30),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: registerButton()
                          ),
                        ),
                      ],
                    ),
                  )
                )
              ),
            ]
          ),
        ),
      ),
    );
  }
}