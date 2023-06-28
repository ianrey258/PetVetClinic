// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart' as ct_res;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Pages/loadingscreen/loadingscreen.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Pages/profile/set_services.dart';
import 'package:vetclinicapp/Services/geo_location.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';



class ClinicProfile extends StatefulWidget {
  const ClinicProfile({super.key});

  @override
  State<ClinicProfile> createState() => _ClinicProfileState();
}

class _ClinicProfileState extends State<ClinicProfile> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _key = GlobalKey<FormState>();
  bool obscure = true;
  ClinicModel? clinic;
  List<String> services = [];
  List<TextEditingController> text = [];

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

  initLoadData()async {
    final id = await DataStorage.getData('id');
    clinic = await ClinicController.getClinic(id);
    setState(() {
      clinic = clinic;
      text[0].text = clinic?.clinic_name??""; 
      text[1].text = clinic?.clinic_doctor??""; 
      text[2].text = clinic?.clinic_email??""; 
      text[3].text = clinic?.clinic_address??"";
      text[4].text = clinic?.clinic_lat??"";
      text[5].text = clinic?.clinic_long??"";
      text[6].text = clinic?.clinic_img??"";
      text[7].text = clinic?.clinic_img_banner??"";
      services = clinic!.services.map((service) => service.toString()).toList();
    });
  }

  validation(){
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      clinic?.clinic_name = text[0].text; 
      clinic?.clinic_doctor = text[1].text; 
      clinic?.clinic_email = text[2].text; 
      clinic?.clinic_address = text[3].text;
      clinic?.clinic_lat = text[4].text;
      clinic?.clinic_long = text[5].text;
      clinic?.clinic_img = text[6].text;
      clinic?.services = services;
      return true;
    }
    return false;
  }

  afterValidation() async {
    var result = await ClinicController.updateClinic(clinic!);
    return result;
  }

  onSubmit() async {   
     if(!(await validation())){
      return CherryToast.error(title: Text("Update Error!"),toastPosition: ct_res.Position.bottom,).show(context);
    }
    LoadingScreen1.showLoadingNoMsg(context);
     if(!(await afterValidation())){
      Navigator.pop(context);
      return CherryToast.error(title: Text("Network Error!"),toastPosition: ct_res.Position.bottom,).show(context);
    }
    Navigator.pop(context);
    return CherryToast.success(title: Text("Update Successfuly!"),toastPosition: ct_res.Position.bottom).show(context); 
  }

  Future<dynamic> showSetServices(List<String> services){
    return showDialog(
      context: context,
      builder: (context) => SetServices(services: services)
    );
  }
  
  Widget _textFormField(String name, int controller, TextInputType type) {
    var read_only = name == "Email Address" ? true : false;
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

    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: TextStyle(color: secondaryColor),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: TextFormField(
              obscureText: obscures,
              readOnly: read_only,
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
              validator: (val) => val!.isNotEmpty ? null : "Invalid " + name,
            ),
          )
        ],
      ),
    );
  }

  Widget resetPassword(){
    return TextButton(
      onPressed: () async {
        ClinicController.sendResetPassword(clinic?.clinic_email??"");
        CherryToast.success(title: Text("Email Sent!")).show(context);
      },
      child: Text("Send Reset Password",style: TextStyle(color: secondaryColor),),
      style: buttonStyleA(100, 50, 10, primaryColor),
    );
  }

  Widget getLocation(){
    return Container(
      child: FilledButton.icon(
        onPressed: () async {
          var result = await LoadingScreen1.showAlertDialog1(context,'Are you sure?',25);
          if(result){  
            Position pos = await GeolocationModule.getPosition();
            setState(() {
              text[4].text = pos.latitude.toString();
              text[5].text = pos.longitude.toString();
            });
          }
        },
        icon: Container(),
        label: Center(
          child: Text('Set Location',style: TextStyle(color: secondaryColor),),
        ),
        style: buttonStyleA(150, 50, 10, primaryColor),
      ),
    );
  }
  
  Widget setServices(){
    return Container(
      child: FilledButton.icon(
        onPressed: () async {
          var services_update = await showSetServices(services);
          print(services_update);
          if(services_update != null){
            setState(() {
              services = services_update; 
            });
          }
        },
        icon: Container(),
        label: Center(
          child: Text('Set Services',style: TextStyle(color: secondaryColor),),
        ),
        style: buttonStyleA(150, 50, 10, primaryColor),
      ),
    );
  }
  
  Widget setScheduleService(){
    return Container(
      padding: EdgeInsets.only(top: 10,bottom: 10),
      child: FilledButton.icon(
        onPressed: () async {
          Navigator.pushNamed(context, '/clinic_schedule');
        },
        icon: Container(),
        label: Center(
          child: Text('Set Service Schedule',style: TextStyle(color: secondaryColor),),
        ),
        style: buttonStyleA(150, 50, 10, primaryColor),
      ),
    );
  }

  Widget imageLoad(String path,double width,double height){
    return path.contains(clinic?.id??"") ? ImageLoader.loadImageNetwork(path,width,height) : ImageLoader.loadImageFile(path,width,height);
  }

  Widget addImage(int index,double width,double height){
    return Center(
      child: TextButton(
        onPressed: () async {
          ImagePicker _picker = ImagePicker();
          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
          if(image != null){
            setState(() {
              text[index].text = image.path;
            });
          }
        },
        child: text[index].text != "" ? imageLoad(text[index].text,width,height) : FaIcon(Icons.image_search,size: 150,color: text2Color,),
      ),
    );
  }

  Widget clinicServices(){
    if(services.isEmpty){
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Wrap(
        children: services.map((service)=>Padding(
          padding:EdgeInsets.all(2.0),
          child: FilterChip(
            backgroundColor: secondaryColor,
            side: BorderSide(color: secondaryColor,),
            label: Text(service,style: TextStyle(color: text1Color,fontSize: 10),),
            onSelected: (value){},
          ) 
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: text1Color,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Image.asset(logoImg,fit: BoxFit.contain),
          actions: [
            Center(
              child: Container(
                padding: EdgeInsets.only(right: 10),
                child: RichText(
                  text: TextSpan(
                    text: "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: text1Color
                    ),
                    recognizer: TapGestureRecognizer()..onTap = ()=> onSubmit()
                  )
                ),
              ),
            )
          ],
        ),
        body: Form(
          key: _key,
          child: Container(
            padding: EdgeInsets.all(10),
            height: size.height,
            child: ListView(
              children: [
                Center(
                  child: Text('Logo',style: TextStyle(fontSize: 20,color: text2Color),),
                ),
                addImage(6,150,150),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text('Banner',style: TextStyle(fontSize: 20,color: text2Color),),
                ),
                addImage(7,250,150),
                Divider(
                  height: 20,
                  color: text3Color,
                ),
                _textFormField("Username",0,TextInputType.name),
                _textFormField("FullName",1,TextInputType.name),
                _textFormField("Address",3,TextInputType.streetAddress),
                _textFormField("Email Address",2,TextInputType.emailAddress),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: resetPassword(),
                ),
                Divider(
                  height: 20,
                  color: text3Color,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Align(
                    child: Text("Clinic Location: (${text[4].text},${text[5].text})",style: TextStyle(color: text2Color),),
                  ),
                ),
                Container(
                  // padding: const EdgeInsets.all(15.0),
                  child: getLocation(),
                ),
                Divider(
                  height: 20,
                  color: text3Color,
                ),
                clinicServices(),
                setServices(),
                setScheduleService(),
              ],
            ),
          ),
        )
      ),
    );
  }
}