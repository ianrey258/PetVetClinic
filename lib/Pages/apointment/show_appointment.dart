import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/AppointmentController.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Controller/PetController.dart';
import 'package:vetclinicapp/Controller/UserController.dart';
import 'package:vetclinicapp/Model/apointmentModel.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Model/petModel.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Services/firebase_messaging.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';


class ShowAppointment extends StatefulWidget {
  final ClinicApointmentModel? apointment;
  const ShowAppointment({Key? key,this.apointment}) : super(key: key);

  @override
  _ShowAppointmentState createState() => _ShowAppointmentState();
}

class _ShowAppointmentState extends State<ShowAppointment> {
  final ScrollController _sc = ScrollController();
  DateTime today = DateTime.now();
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  String payment = ''; 
  String schedule = ''; 
  ClinicModel? clinic;
  UserModel? user;
  ClinicApointmentModel? apointment;
  List<String> status = ['Pending','Approved','Declined'];
  List<PetModel> pets = [];

  @override
  initState() {
    super.initState();
    setState(() {
      for (int i = 0; i < 10; i++) {
        text.add(TextEditingController());
      }
      apointment = widget.apointment;
    });
    initLoadData();
  }

  initLoadData() async {
    ClinicModel _clinic = await ClinicController.getClinic(apointment?.clinic_id??"");
    UserModel _user = await UserController.getUser(apointment?.pet_owner_id??"");
    apointment?.pet_list_ids?.forEach((id) async {
      PetModel pet = await PetController.getPet(id);
      setState(() {
        pets.add(pet);
      });  
    });
    if(apointment?.clinic_read_status == "" || apointment?.clinic_read_status == "false" || apointment?.pet_owner_read_status == null){
      apointment?.clinic_read_status = 'true';
      await ApointmentController.setApointment(apointment!);
    }
    if(apointment != null){
      setState(() {
        clinic = _clinic;
        user = _user;
        apointment?.clinic_read_status = 'true';
        text[0].text = apointment?.reason??"";
        DateTime sched = DateTime.parse(apointment?.schedule_datetime??"");
        text[1].text = "${DateFormat.yMMMEd().add_jm().format(sched)}";
      });
    }
  }

  void reSchedule() async {
     DateTime sched = DateTime.parse(apointment?.schedule_datetime??"");
    final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: sched ?? DateTime.now(),
                          lastDate: DateTime(2100)
                        );
    if (date != null) {
      final time = await showTimePicker(context: context,initialTime:TimeOfDay.fromDateTime(sched ?? DateTime.now()),);
      setState(() {
        apointment?.schedule_datetime = DateTimeField.combine(date, time).toString();
        apointment?.pet_owner_read_status = 'false';
      });
      if(await ApointmentController.updateApointment(apointment!)){
        FirebaseMessagingService.sendMessageNotification('Appointment', "Doc ${await DataStorage.getData('username')}", 'Reschedule Apointment', '${user?.fullname} your schedule will be moved on ${apointment?.schedule_datetime}', user!.fcm_tokens!);
        Navigator.pop(context);
        CherryToast.success(title: Text('Appointment Postponed')).show(context);
      }else{
        CherryToast.error(title: Text('Appointment Postponed Error')).show(context);
      }
    }
  }

  Widget _textFormField(String name, int controller, TextInputType type) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: TextFormField(
              keyboardType: type,
              maxLines: TextInputType.multiline == type ? 4 : null,
              minLines: TextInputType.multiline == type ? 4 : null,
              expands: false,
              readOnly: true,
              controller: text[controller],
              style: TextStyle(fontSize: 18, color: secondaryColor),
              cursorColor: secondaryColor,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                fillColor: text3Color,
                filled: true,
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

  Widget getDateAppointment(int controller){
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(15),
        fillColor: text3Color,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none
        ),
        hintText: 'DateTime'
      ),
      readOnly: true,
      controller: text[controller],
    );
  }

  Widget pet(PetModel pet){
    return Container(
      margin: EdgeInsets.only(top: 5,bottom: 5),
      height: 60,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        color: text1Color,
        margin: EdgeInsets.all(1),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10)
            ),
            // child: Image.asset(image,height: double.infinity,width: 50)
            child: pet?.pet_img != null && pet?.pet_img != "" ? ImageLoader.loadImageNetwork(pet?.pet_img??"",50.0,50.0) : FaIcon(Icons.pets,size: 50,)
          ),
          title: Text(pet.pet_name??"",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: text2Color),),
          trailing: Container(
            width: 50,
            height: double.infinity,
          ),
          onTap: (){
          },
        ),
      ),
    );
  }

  Widget petList(){
    return Container(
      height: 200,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pets.map((PetModel _pet) => pet(_pet)).toList(),
        ),
      )
    );
  }

  Color statusColor(status){
    if(status == "Approved"){
      return text9Color;
    }
    if(status == "Declined"){
      return text4Color;
    }
    return text6Color;
  }

  Widget formAppointment(){
    return Form(
      key: _key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(apointment?.status??"",style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold, color: statusColor(apointment?.status??"")),),
          _textFormField("Reason", 0, TextInputType.multiline),
          getDateAppointment(1),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('Pets',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: petList(),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
            style: buttonStyleA(250,50,1,primaryColor),
            onPressed: () => Navigator.popAndPushNamed(context, '/message',arguments: user), 
            child: Center(
              child: Text('Message'),
            )
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
            style: buttonStyleA(250,50,1,text9Color),
            onPressed: () async => reSchedule(), 
            child: Center(
              child: Text('Re-Schedule'),
            )
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
            style: buttonStyleA(250,50,1,text4Color),
            onPressed: () => Navigator.pop(context,false), 
            child: Center(
              child: Text('Decline'),
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return AlertDialog(
      content: Container(
        height: size.height*.55,
        child: SizedBox(
          height: size.height*.30,
          width: double.infinity,
          child: SingleChildScrollView(
            child: formAppointment()
          ),
        ),
      ),
    );
  }
}
