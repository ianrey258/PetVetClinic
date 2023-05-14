// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Pages/LoadingScreen/LoadingScreen.dart';
import 'package:vetclinicapp/Services/geo_location.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';


class Register3 extends StatefulWidget {
  final List<TextEditingController>? text;
  const Register3({super.key,this.text});

  @override
  State<Register3> createState() => _Register3State();
}

class _Register3State extends State<Register3> {
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  int last_index = 0;
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
        if(!validation()){
          return null; 
        }
        Navigator.pushNamed(context, '/register4', arguments: text);
      },
    );
  }

  Widget getLocation(){
    return Center(
      child: FilledButton.icon(
        onPressed: () async {
          Position pos = await GeolocationModule.getPosition();
          setState(() {
            text[last_index + 1].text = pos.latitude.toString();
            text[last_index + 2].text = pos.longitude.toString();
          });
        },
        icon: Container(),
        label: Center(
          child: Text('Get Location'),
        ),
        style: buttonStyleA(150, 50, 10, primaryColor),
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
                          "Clinic Location",
                          style: TextStyle(
                            fontSize: 30
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        child:Text(
                          "Let us know your clinic location",
                          style: TextStyle(
                            fontSize: 15
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        child:Text(
                          "for your dear customers",
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
                          child: Text('Make sure on the clinic location'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: Text("Location: (${text[last_index + 1].text},${text[last_index + 2].text})"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: getLocation(),
                        ),
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