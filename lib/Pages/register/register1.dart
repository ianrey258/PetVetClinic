// ignore_for_file: prefer_const_constructors

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Pages/LoadingScreen/LoadingScreen.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';


class Register1 extends StatefulWidget {
  const Register1({super.key});

  @override
  State<Register1> createState() => _Register1State();
}

class _Register1State extends State<Register1> {
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
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

  Widget _textFormField(String name, int controller, TextInputType type) {
    var obscures = name != 'Password' ? false : obscure;
    Widget showPassword = name != 'Password'
        ? SizedBox.shrink()
        : IconButton(
            icon: FaIcon(
              FontAwesomeIcons.eyeSlash,
              color: secondaryColor,
            ),
            onPressed: () {
              setState(() {
                obscure = obscure ? false : true;
              });
            },
          );

    var validateFunc = (val) => val!.isNotEmpty ? null : "Invalid " + name;
    if(name == "Email"){
      RegExp checker = new RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
      validateFunc = (val) => val!.isNotEmpty && checker.hasMatch(val) ? null : "Invalid " + name;
    }

    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: TextStyle(color: text1Color),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: TextFormField(
              obscureText: obscures,
              keyboardType: type,
              controller: text[controller],
              style: TextStyle(fontSize: 18, color: secondaryColor),
              cursorColor: secondaryColor,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                fillColor: text3Color,
                filled: true,
                // labelText: name,
                suffixIcon: showPassword,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none
                ),
              ),
              validator: validateFunc,
            ),
          )
        ],
      ),
    );
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
        if(!validation()){
          return; 
        }
        LoadingScreen1.showLoading(context, "Checking Email");
        if(await ClinicController.isInEmail(text[2].text)){
          Navigator.pop(context);
          return CherryToast.error(title: Text("Email is already exist!")).show(context);
        }
        Navigator.pop(context);
        Navigator.pushNamed(context, '/register2', arguments: text);
      },
    );
  }

  Widget loginTextButton(){
    return RichText(
      text:TextSpan(
        text: "Already have an Account!",
        style: TextStyle(
          color: primaryColor
        ),
        recognizer: TapGestureRecognizer()..onTap =(){
          Navigator.popAndPushNamed(context, '/login');
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
                          "Register Account",
                          style: TextStyle(
                            fontSize: 30
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        child:Text(
                          "Full your details or continue",
                          style: TextStyle(
                            fontSize: 15
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        child: Text(
                          "social media",
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
                        _textFormField("Clinic Name", 0, TextInputType.text),
                        _textFormField("Doctor Name", 1, TextInputType.text),
                        _textFormField("Email", 2, TextInputType.emailAddress),
                        _textFormField("Address", 3, TextInputType.text),
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: _textFormField("Password", 4, TextInputType.visiblePassword),
                        ),
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