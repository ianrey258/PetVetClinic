import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Pages/loadingscreen/loadingscreen.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SetSchedule extends StatefulWidget {
  final List<String>? services;
  const SetSchedule({Key? key,this.services}) : super(key: key);

  @override
  _SetSchedule createState() => _SetSchedule();
}

class _SetSchedule extends State<SetSchedule> {
  final ScrollController _sc = ScrollController();
  List<TextEditingController> text = [];
  List<String> in_sched_days = [];
  ClinicScheduleModel? schedule_model = ClinicScheduleModel('','','','',0);
  final _key = GlobalKey<FormState>();
  ClinicModel? clinic;
  String selected_day = '';
  String time_open = '';
  String time_close = '';
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final datetime_format = DateFormat.jm();
  Map days_order = {
                    'sun':1,
                    'mon':2,
                    'tue':3,
                    'wed':4,
                    'thu':5,
                    'fri':6,
                    'sat':7,
                    };
  Map days_label = {
                    'sun':'Sunday',
                    'mon':'Monday',
                    'tue':'Tuesday',
                    'wed':'Wednesday',
                    'thu':'Thursday',
                    'fri':'Friday',
                    'sat':'Saturday',
                    };
  List days = [
              {'value':'sun','label':'Sunday'},
              {'value':'mon','label':'Monday'},
              {'value':'tue','label':'Tuesday'},
              {'value':'wed','label':'Wednesday'},
              {'value':'thu','label':'Thursday'},
              {'value':'fri','label':'Friday'},
              {'value':'sat','label':'Saturday'}
  ];

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
    });
  }

  bool validation(){
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      if(text[0].text.isEmpty && text[1].text.isEmpty && text[2].text.isEmpty){
        return false;
      }
      DateTime time_in = DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${time_open}');
      DateTime time_out = DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${time_close}');
      if(time_in.microsecondsSinceEpoch > time_out.microsecondsSinceEpoch){
        return false;
      }
      if(in_sched_days.contains(days_label[selected_day])){
        return false;
      }
      setState(() {
        schedule_model?.clinic_day = days_label[selected_day];
        schedule_model?.clinic_opening = time_open;
        schedule_model?.clinic_closing = time_close;
        schedule_model?.order = days_order[selected_day];
      });
      return true;
    }
    return false;
  }

  Widget _dropDownFormField(String name, int controller) {
    List<DropdownMenuEntry> choices = [];
    var size = MediaQuery.of(context).size;
    choices = days.map((data) => DropdownMenuEntry(value: data['value'], label: data['label'])).toList();
    return Container(
      padding: EdgeInsets.all(5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose ${name}',
              style: TextStyle(color: text2Color,fontSize: 15),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            child: DropdownMenu(
              width: size.width*.98,
              menuStyle: MenuStyle(
                maximumSize: MaterialStateProperty.all(Size.infinite)
              ),
              controller: text[controller],
              initialSelection: text[controller].text,
              dropdownMenuEntries: choices,
              inputDecorationTheme: InputDecorationTheme(
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
              onSelected: (value){
                setState(() {
                  selected_day = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _textDateTimeField(String name, int controller){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: DateTimeField(
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
          hintText: name
        ),
        format: datetime_format,
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(context: context,initialTime:TimeOfDay.fromDateTime(currentValue ?? DateTime.now()));
          
          setState(() {
            text[controller].text =  DateFormat.jm().format(DateTimeField.combine(DateTime.now(), time)).toString();
            // print(DateFormat.jm().format(DateTimeField.combine(DateTime.now(), time)).toString()); 
            if(controller == 1){
              time_open = DateFormat('HH:mm:ss.SSS').format(DateTimeField.combine(DateTime.now(), time));
            }
            if(controller == 2){
              time_close = DateFormat('HH:mm:ss.SSS').format(DateTimeField.combine(DateTime.now(), time));
            }
          });
          return DateTimeField.combine(DateTime.now(), time);
        },
      ),
    );
  }

  Widget setScheduleButton(){
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5),
      child: TextButton.icon(
        icon: Padding(
          padding: EdgeInsets.only(left: 8),
          child: FaIcon(FontAwesomeIcons.plus,color: text1Color, size: 30,),
        ),
        label: Text("",),
        style: buttonStyleA(100, 50, 10, primaryColor),
        onPressed: () async {
          if(!validation()){
            return CherryToast.error(title: Text("Error Input!"),toastPosition: Position.bottom).show(context);
          }
          if(!await ClinicController.setClinicSchedule(schedule_model!)){
            return CherryToast.error(title: Text("Error Add Schedule")).show(context);
          }
        },
      ),
    );
  }
  
  Widget removeScheduleButton(ClinicScheduleModel schedule){
    return TextButton.icon(
      icon: Padding(
        padding: EdgeInsets.only(left: 8),
        child: FaIcon(FontAwesomeIcons.minus,color: text1Color, size: 30,),
      ),
      label: Text(""),
      style: buttonStyleA(20, 40, 10, text4Color),
      onPressed: () async {
        if(!await ClinicController.removeClinicSchedule(schedule)){
          return CherryToast.error(title: Text("Error Remove Schedule")).show(context);
        }
      },
    );
  }

  Widget setSchedule(){
    return Form(
      key: _key,
      child: SizedBox(
        child: Column(
          children: [
            _dropDownFormField('Day',0),
            Row(
              children: [
                Flexible(
                  child: _textDateTimeField('Opening Time',1)
                ),
                Flexible(
                  child: _textDateTimeField('Closing Time',2)
                )
              ],
            ),
            setScheduleButton()
          ],
        ),
      ),
    );
  }
  
  Widget scheduleContainer(snapshot){
    ClinicScheduleModel schedule = ClinicScheduleModel.fromMap(jsonDecode(jsonEncode(snapshot)));
    String time_in = DateFormat.jm().format(DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${schedule.clinic_opening}'));
    String time_out = DateFormat.jm().format(DateTime.parse('${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${schedule.clinic_closing}'));
    in_sched_days.add(schedule.clinic_day??'');
    return ListTile(
      title: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Text(schedule.clinic_day??'',style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.left,)
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text('${time_in} - ${time_out}'))
          )
        ],
      ),
      trailing: removeScheduleButton(schedule),
    );
  }
  
  Widget listSchedules(){
    if(clinic?.id == '' || clinic?.id == null){
      return Flexible(
        child: Container()
      );
    }
    return Flexible(
      child: StreamBuilder(
        initialData: [],
        stream: ClinicController.getClinicScheduleSnapshots(clinic?.id??''),
        builder: (BuildContext context,AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
            List listMessages = snapshot.data.docs;
            in_sched_days = [];
            if (listMessages.isNotEmpty) {
              return ListView(
                  padding: const EdgeInsets.all(10),
                  controller: _sc,
                  children: listMessages.map((snapshot) => scheduleContainer(snapshot.data())).toList()
                );
            } else {
              return const Center(
                child: Text('No Service Schedule'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
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
          title: Text('Clinic Schedule'),
        ),
        body: Container(
          height: size.height,
          child: Column(
            children: [
              setSchedule(),
              Divider(
                height: 10,
              ),
              listSchedules()
            ],
          ),
        ),
      ),
    );
  }
}
