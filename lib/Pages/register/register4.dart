// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Pages/LoadingScreen/LoadingScreen.dart';
import 'package:filter_list/filter_list.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';


class Register4 extends StatefulWidget {
  final List<TextEditingController>? text;
  const Register4({super.key,this.text});

  @override
  State<Register4> createState() => _Register4State();
}

class _Register4State extends State<Register4> {
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  List<ClinicService> selectedClinicServices = [];
  List listServices = [];
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
        text[last_index! + 1].text = jsonEncode(listServices);
        text = filterTextEdititor(text);
      });
      return true;
    }
    return false;
  }

  Future afterValidation() async {
    LoadingScreen1.showLoadingNoMsg(context);
    try {
      var result = await ClinicController.registerClinic(text);
      return result;
    } catch (e) {
      return false;
    }
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
      style: buttonStyleA(30, 50, 10, primaryColor),
      onPressed: () async {
        if(!validation()){
          return null; 
        }
        if(!await afterValidation()){
          Navigator.pop(context);
          return CherryToast.error(title: Text('Somethings Wrong on the Network')).show(context);
        }
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.popAndPushNamed(context, '/loading_screen');
      },
    );
  }

  Widget filterServices(){
    return FilterListWidget(
      themeData: FilterListThemeData(
        context,
        backgroundColor: secondaryColor,
        controlButtonBarTheme: ControlButtonBarThemeData(
          context,
          backgroundColor: text0Color
          )
      ),
      hideHeader: true,
      listData: ClinicService.getSampleServices(),
      selectedListData: selectedClinicServices,
      hideSearchField: true,
      hideSelectedTextCount: true,
      controlButtons: [],
      validateSelectedItem: (selectedClinicServices,selected){
        return selectedClinicServices!.contains(selected);
      }, 
      choiceChipLabel: (item){
        return item!.name;
      }, 
      onItemSearch: (data,item){
        return true;
      },
      applyButtonText: 'Apply and Register',
      onApplyButtonClick: (list) async {
        setState(() {
          listServices = [];
        });
        selectedClinicServices = list!;
        selectedClinicServices!.forEach((ClinicService element) {
          if(!listServices.contains(element.name)){
            listServices.add(element.name);
          }   
        });
        if(!validation()){
          return null; 
        }
        if(!await afterValidation()){
          Navigator.pop(context);
          return CherryToast.error(title: Text('Somethings Wrong on the Network')).show(context);
        }
        Future.delayed(Duration(seconds: 3),(){
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.popAndPushNamed(context, '/loading_screen');
        });
      },
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
                          "Clinic Services",
                          style: TextStyle(
                            fontSize: 30
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        child:Text(
                          "Select your clinic services",
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
                flex: 6,
                child: Form(
                  key: _key,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height*.5,
                          child: filterServices()
                        ),
                      ],
                    ),
                  )
                )
              ),
              Expanded(
                flex: 1,
                child: Container(
                  // child: Text("By Continuing you agree to "),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("By Continuing you agree to "),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "our "
                            ),
                            TextSpan(
                              text: "terms and conditions",
                              style: TextStyle(
                                fontWeight: FontWeight.bold 
                              ),
                              recognizer: TapGestureRecognizer()..onTap =() => {}
                            )
                          ]
                        )
                      ),
                    ],
                  ),
                )
              ),
            ]
          ),
        ),
      ),
    );
  }
}