import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/AppointmentController.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Controller/UserController.dart';
import 'package:vetclinicapp/Model/apointmentModel.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Pages/LoadingScreen/loadingscreen.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Pages/apointment/show_appointment.dart';
import 'package:vetclinicapp/Services/firebase_messaging.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';

class Apointments extends StatefulWidget {
  const Apointments({Key? key}) : super(key: key);

  @override
  _ApointmentsState createState() => _ApointmentsState();
}

class _ApointmentsState extends State<Apointments> {
  final ScrollController _sc = ScrollController();
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  List<Map<String,Object>> apointments = [];
  List<String> status = ['Pending','Approved','Declined','Completed'];
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
    apointments = [];
    List _apointments = await ApointmentController.getApointments();
    debugPrint(_apointments.length.toString());
    _apointments.forEach((apointment) async {
      if(apointment.status.toString() == status[1] || apointment.status.toString() == status[3]){
        debugPrint(apointment.pet_owner_id);
        UserModel _user = await UserController.getUser(apointment.pet_owner_id??'');
        setState(() {  
          apointments.add({
            "apointment":apointment,
            "user": _user,
          });
        });
      }
    });
  }

  refreshPage(){
    refresh = !refresh;
  }

  void removeApointment(ClinicApointmentModel apointment, UserModel user) async {
    if(await LoadingScreen1.showAlertDialog1(context,'Are you sure to cancel?',18)){
      await ApointmentController.removeApointment(apointment.id??"");
      setState(() {
        apointments.removeWhere((data) => data['apointment'] == apointment);
      });
      FirebaseMessagingService.sendMessageNotification(notification_type[1], "Doc ${await DataStorage.getData('username')}", 'Decline Apointment', '${user.fullname} your Apointment Schedule Has Been Cancel ', user.fcm_tokens!,{});
      CherryToast.success(title: Text("Remove Successfuly!")).show(context);
    }
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

  Future<dynamic> showAppointment(ClinicApointmentModel _apointment){
    return showDialog(
      context: context,
      builder: (context) => ShowAppointment(apointment: _apointment)
    );
  }

  Widget apointment(Map _apointments) {
    ClinicApointmentModel? apointment = _apointments['apointment'];
    UserModel? user = _apointments['user'];
    return Card(
      elevation: 5,
      child: ListTile(
        style: ListTileStyle.list,
        leading: user?.profile_img != "" ? ImageLoader.loadImageNetwork(user?.profile_img??"",50.0,50.0) : FaIcon(Icons.store,size: 50),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(user?.username??""),
            Text("${DateFormat.yMd().format(DateTime.parse(apointment?.schedule_datetime??""))}")
          ],
        ),
        subtitle: Text(apointment?.status??""),
        trailing: Container(
          // width: 90,
          child: IconButton(
            icon: FaIcon(Icons.cancel,size: 35,color: text4Color,),
            onPressed: () async => removeApointment(apointment!,user!),
          ),
        ),
        onTap: ()=> showAppointment(apointment!),
      ),
    );   
  }
  
  Widget apointmentCompleted(Map _apointments) {
    ClinicApointmentModel? apointment = _apointments['apointment'];
    UserModel? user = _apointments['user'];
    return Card(
      elevation: 5,
      child: ListTile(
        style: ListTileStyle.list,
        leading: user?.profile_img != "" ? ImageLoader.loadImageNetwork(user?.profile_img??"",50.0,50.0) : FaIcon(Icons.store,size: 50),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(user?.username??""),
            Text("${DateFormat.yMd().format(DateTime.parse(apointment?.schedule_datetime??""))}")
          ],
        ),
        subtitle: Text(apointment?.status??""),
        onTap: ()=> showAppointment(apointment!),
      ),
    );   
  }

  List<Widget> apointmentList(){
    List<Map> is_not_completed = apointments.where((Map data) => data['apointment'].status != 'Completed').toList();
    List<Map> is_completed = apointments.where((Map data) => data['apointment'].status == 'Completed').toList();
    if(apointments.isEmpty){
      return [
        Center(
          heightFactor: 2,
          child: Text("No Apointments",style: TextStyle(color: text2Color),)
        )
      ];
    }
    return is_not_completed.map((Map data) => apointment(data)).toList() + [Divider(thickness: 2,height: 8,)] + is_completed.map((Map data) => apointmentCompleted(data)).toList();
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
        body: RefreshIndicator(
          onRefresh: () => initLoadData(),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: ListView(
              children: apointmentList(),
            ),
          ),
        ),
      ),
    );
  }
}
