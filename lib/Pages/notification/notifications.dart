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
import 'package:vetclinicapp/Pages/notification/show_appointment_notif.dart';
import 'package:vetclinicapp/Services/firebase_messaging.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final ScrollController _sc = ScrollController();
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  ClinicModel? clinic;
  List<Map<String,Object>> apointments = [];
  List<String> status = ['Pending','Approved','Declined'];
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
    _apointments.forEach((apointment) async {
      if(apointment.status.toString() == status[0]){
        UserModel clinic = await UserController.getUser(apointment.pet_owner_id??'');
        setState(() {  
          apointments.add({
            "apointment":apointment,
            "user": clinic,
          });
        });
      }
    });
  }

  refreshPage(){
    refresh = !refresh;
  }

  Future setStatusApointment(ClinicApointmentModel apointment,String _status,UserModel? user) async {
    if(_status == status[1]){
      apointment.status = status[1];
      apointment.clinic_read_status = 'true';
      apointment.pet_owner_read_status = 'false';
      await ApointmentController.updateApointment(apointment);
      FirebaseMessagingService.sendMessageNotification(notification_type[1], "Doc ${await DataStorage.getData('username')}", 'Accept Apointment', '${user?.fullname} your Apointment Schedule Has Been Accepted ', user!.fcm_tokens!,{});
      setState(() {
        apointments.removeWhere((data) => data['apointment'] == apointment);
      });
      CherryToast.success(title: Text("Accept Apointment!")).show(context);
    }
    if(_status == status[2] && await LoadingScreen1.showAlertDialog1(context, "Are you sure to Decline?", 18)){
      apointment.status = status[2];
      apointment.clinic_read_status = 'true';
      apointment.pet_owner_read_status = 'false';
      await ApointmentController.updateApointment(apointment);
      FirebaseMessagingService.sendMessageNotification(notification_type[1], "Doc ${await DataStorage.getData('username')}", 'Decline Apointment', '${user?.fullname} your Apointment Schedule Has Been Cancel ', user!.fcm_tokens!,{});
      setState(() {
        apointments.removeWhere((data) => data['apointment'] == apointment);
      });
      CherryToast.success(title: Text("Decline Apointment!")).show(context);
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

  Future<dynamic> showAppointment(ClinicApointmentModel _apointment,UserModel? user) async {
    var result = await showDialog(
      context: context,
      builder: (context) => ShowAppointmentNotif(apointment: _apointment)
    );
    if(result == true){
      await setStatusApointment(_apointment,status[1],user);
    }
    if(result == false){
      await setStatusApointment(_apointment,status[2],user);
    }
  }

  Widget apointment(Map _apointments) {
    ClinicApointmentModel? apointment = _apointments['apointment'];
    UserModel? user = _apointments['user'];
    String date_sched = DateFormat.yMd().format(DateTime.parse(apointment?.schedule_datetime??""));
    return Card(
      elevation: 5,
      child: ListTile(
        leading: user?.profile_img != "" ? ImageLoader.loadImageNetwork(user?.profile_img??"",50.0,50.0) : FaIcon(FontAwesomeIcons.user,size: 50),
        title: Text(user?.fullname??""),
        subtitle: Text("${date_sched}"),
        trailing: Container(
          width: 100,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: FaIcon(Icons.check_circle,size: 35,color: text9Color,),
                onPressed: () async => setStatusApointment(apointment!,status[1],user),
              ),
              IconButton(
                icon: FaIcon(Icons.cancel,size: 35,color: text4Color,),
                onPressed: () async => setStatusApointment(apointment!,status[2],user),
              ),
            ],
          ),
        ),
        onTap: ()async => showAppointment(apointment!,user),
      ),
    );   
  }

  List<Widget> apointmentList(){
    if(apointments.isEmpty){
      return [Center(child: Text("No Apointment"),)];
    }
    return apointments.map((Map data) => apointment(data)).toList();
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
          onRefresh: ()=> initLoadData(),
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
