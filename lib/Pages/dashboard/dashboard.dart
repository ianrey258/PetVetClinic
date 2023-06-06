// ignore_for_file: prefer_const_constructors
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:banner_carousel/banner_carousel.dart';
import 'package:vetclinicapp/Controller/AppointmentController.dart';
import 'package:vetclinicapp/Controller/ClinicController.dart';
import 'package:vetclinicapp/Controller/FileController.dart';
import 'package:vetclinicapp/Controller/UserController.dart';
import 'package:vetclinicapp/Model/apointmentModel.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Pages/apointment/show_appointment.dart';
import 'package:vetclinicapp/Pages/loadingscreen/loadingscreen.dart';
import 'package:vetclinicapp/Services/firebase_messaging.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';
import 'package:badges/badges.dart' as badges;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<TextEditingController> text = [];
  int unread_appointment = 0;
  final _key = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool obscure = true;
  ClinicModel? clinic;
  final ImagePicker _picker = ImagePicker();
  List<Map<String,Object>> apointments = [];
  List<String> status = ['Pending','Approved','Declined'];
  List<BannerModel> listBanners = [
    BannerModel(imagePath: 'assets/images/puppy.png', id: "1",boxFit: BoxFit.contain),
    BannerModel(imagePath: 'assets/images/puppy.png', id: "2",boxFit: BoxFit.contain),
    BannerModel(imagePath: 'assets/images/puppy.png', id: "3",boxFit: BoxFit.contain),
    BannerModel(imagePath: 'assets/images/puppy.png', id: "4",boxFit: BoxFit.contain),
  ];

  @override
  initState() {
    super.initState();
    setState(() {
      for (int i = 0; i < 10; i++) {
        text.add(TextEditingController());
      }
    });
    FirebaseMessagingService.initPermission();
    FirebaseMessagingService.initListenerForground(context);
    FirebaseMessagingService.awesomeNotificationButtonListener(context);
    initLoadData();
    setUnreadApointmentBadge();
  }

  initLoadData()async {
    final id = await DataStorage.getData('id');
    ClinicModel _clinic = await ClinicController.getClinic(id);
    setState(() {  
      clinic = _clinic;
    });

    apointments = [];
    List _apointments = await ApointmentController.getApointments();
    _apointments.forEach((apointment) async {
      DateTime sched = DateTime.parse(apointment.schedule_datetime);
      if(apointment.status.toString() == status[1] && DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(sched)){
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

  validation() async {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      // LoadingScreen1.showLoadingNoMsg(context);
      // try {
      //   var result = await FirebaseController.loginUser(text);
      //   return result;
      // } catch (e) {
      //   return false;
      // }
    }
    return false;
  }

  Future setUnreadApointmentBadge() async {
    List user_appointment_list = await ApointmentController.getUnreadApointments()??[];
    if(unread_appointment != user_appointment_list.length){
      setState(() {
        unread_appointment = user_appointment_list.length;
      });
    }
  }

  logout(){
    ClinicController.logoutClinic();
    Navigator.popAndPushNamed(context,'/loading_screen');
  }

  Widget drawerContainerItem(icon,text){
    return ListTile(
      leading: FaIcon(icon,size: 25,color: text1Color,),
      title: "Notification" == text && unread_appointment != 0 ? Container(
        child: badges.Badge(
          position: badges.BadgePosition.topEnd(top: -10, end: -12),
          showBadge: true,
          ignorePointer: false,
          onTap: () {},
          badgeContent: Text(unread_appointment.toString()),
          child: Text(text,style: TextStyle(fontSize: 25),),
        ), 
      ) : Text(text,style: TextStyle(fontSize: 25),),
      trailing: Icon(Icons.arrow_forward_ios_sharp,color: text1Color,),
      onTap: (){
        Navigator.pop(context);
        text == "Home" ? _scaffoldKey.currentState?.closeDrawer()
        : text == "Notification" ? Navigator.pushNamed(context, '/notifications')
        : text == "Apointment" ? Navigator.pushNamed(context, '/apointments')
        : text == "Messages" ? Navigator.pushNamed(context, '/messages')
        : text == "History" ? ''
        : text == "Reviews" ? Navigator.pushNamed(context, '/rating_reviews') 
        : text == "Settings" ? Navigator.pushNamed(context, "/clinic_profile")
        : text == "Logout" ? logout()
        : null;
      },
    );
  }

  Widget profileImage(){
    return IconButton(
      onPressed: () async {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if(image != null){
          String img_path = await ClinicController.updateClinicLogo(image?.path??"");
          Future.delayed(Duration(seconds: 2),(){
            setState(() {
              clinic?.clinic_img = img_path;
            });
          });
        }
      }, 
      icon: CircleAvatar(
        radius: 100,
        backgroundColor: text0Color,
        child: ClipOval(
          child: clinic?.clinic_img != "" ? ImageLoader.loadImageNetwork(clinic?.clinic_img??"",150.0,150.0) : FaIcon(FontAwesomeIcons.circleUser,size: 150,color: text1Color,),
        ),
      )
    );
  }

  Widget drawerContainer(){
    return ListView(
      children: [        
        SizedBox(
          height: 200,
          child: Container(
            child: profileImage()
          ),
        ),
        SizedBox(
          height: 50,
          child: Center(
            child: Text(clinic?.clinic_name??"",style: TextStyle(fontSize: 25),),
          ),
        ),
        drawerContainerItem(Icons.home,'Home'),
        drawerContainerItem(FontAwesomeIcons.message,'Notification'),
        drawerContainerItem(Icons.schedule_outlined,'Apointment'),
        drawerContainerItem(FontAwesomeIcons.message,'Messages'),
        // drawerContainerItem(Icons.history,'History'),
        drawerContainerItem(Icons.reviews_outlined,'Reviews'),
        // drawerContainerItem(FontAwesomeIcons.userGear,'Settings'),
        drawerContainerItem(Icons.logout,'Logout'),
      ],
    );
  }

  BottomNavigationBarItem buttomNavigationItem(icon){
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: FaIcon(icon),
      ),
      label: ""
    );
  }

  Widget greetings(){
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Column(
        // textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5,left: 5),
            child: Text('Hello! Doc',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: text2Color),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5,left: 5),
            child: Text('${clinic?.clinic_doctor??""}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: text2Color),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5,left: 5),
            child: Text('Good Morning!',style: TextStyle(fontSize: 20,color: text2Color),),
          )
        ],
      ),
    );
  }
  
  Widget feeds(){
    return SizedBox(
      height: 210,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(          
        ),
        child: BannerCarousel(
          banners: listBanners,
          margin: EdgeInsets.only(left: 10,right: 10),
          borderRadius: 10,
          height: 200,
          viewportFraction: .9,
          indicatorBottom: true,
          showIndicator: false,
          initialPage: 1,
        ),
      ),
    );
  }

  Widget categoryFilterItem(icon,text){
    return Container(
      height: 150,
      width: 100,
      padding: EdgeInsets.only(left: 5,right: 5),
      child: Column(
        children: [
          ElevatedButton(
            style: buttonStyleA(100,100,20,secondaryColor),
            onPressed: (){}, 
            child: Center(
              child: FaIcon(icon,size: 60,),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(text,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: text7Color),),
          )
        ],
      ),
    );
  }
  
  Widget categoryFilter(){
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            categoryFilterItem(FontAwesomeIcons.paw,'Mammals'),
            categoryFilterItem(FontAwesomeIcons.staffSnake,'Reptile'),
            categoryFilterItem(FontAwesomeIcons.fish,'Fish'),
            categoryFilterItem(FontAwesomeIcons.dove,'Birds'),
            categoryFilterItem(FontAwesomeIcons.frog,'Amphibians'),
          ],
        ),
      ),
    );
  }

  void removeApointment(ClinicApointmentModel apointment, UserModel user) async {
    if(await LoadingScreen1.showAlertDialog1(context,'Are you sure to cancel?',18)){
      await ApointmentController.removeApointment(apointment.id??"");
      setState(() {
        apointments.removeWhere((data) => data['apointment'] == apointment);
      });
      FirebaseMessagingService.sendMessageNotification(notification_type[1], "Doc ${await DataStorage.getData('username')}", 'Remove Apointment', '${user.fullname} your Apointment Schedule Has Been Cancel ', user.fcm_tokens!,{});
      CherryToast.success(title: Text("Remove Successfuly!")).show(context);
    }
  }

  Future<dynamic> showAppointment(ClinicApointmentModel _apointment,UserModel? user) async {
    // return showDialog(
    //   context: context,
    //   builder: (context) => ShowAppointment(apointment: _apointment)
    // );

    var result = await showDialog(
      context: context,
      builder: (context) => ShowAppointment(apointment: _apointment)
    );
    if(result == false){
      removeApointment(_apointment,user!);
    }
  }

  Widget apointmentCard(Map data){
    ClinicApointmentModel? apointment = data['apointment'];
    UserModel? user = data['user'];
    return Card(
      elevation: 2,
      child: ListTile(
        style: ListTileStyle.list,
        leading: user?.profile_img != "" ? ImageLoader.loadImageNetwork(user?.profile_img??"",50.0,50.0) : FaIcon(Icons.store,size: 50),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(user?.username??""),
            Text("${DateFormat.jm().format(DateTime.parse(apointment?.schedule_datetime??""))}")
          ],
        ),
        subtitle: Wrap(
          children: [
            Text(apointment?.reason??"")
          ]
        ),
        trailing: Container(
          // width: 90,
          child: IconButton(
            icon: FaIcon(Icons.message,size: 35,color: primaryColor,),
            onPressed: () => Navigator.pushNamed(context, '/message',arguments: user),
          ),
        ),
        onTap: ()=>  showAppointment(apointment!,user),
      ),
    );   
  }

  List<Widget> todayAppointment(){
    // return ClinicData.getSampleData().map((data) => vetClinic(data)).toList();
    if(apointments.isEmpty){
      return [];
    }
    return apointments.map((data) => apointmentCard(data)).toList();
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
          leading: Container(),
          actions: [],
        ),
        body: RefreshIndicator(
          onRefresh: ()=> initLoadData(),
          child: Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            width: double.infinity,
            height: double.infinity,
            child: ListView(
              children: [
                greetings(),
                feeds(),
                Text("Todays Apointment",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: text2Color),),
              ] + todayAppointment(),
            ),
          )
        ),
        drawer: Drawer(
          width: size.width*.7,
          backgroundColor: alternativeColor,
          child: drawerContainer(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: secondaryColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: text1Color,
          currentIndex: 1,
          elevation: 0,
          // ignore: prefer_const_literals_to_create_immutables
          items: [
            buttomNavigationItem(FontAwesomeIcons.bars),
            buttomNavigationItem(FontAwesomeIcons.house),
          ],
          onTap: (value) {
            if(value == 0){
              setUnreadApointmentBadge();
              _scaffoldKey.currentState?.openDrawer();
            }
            if(value == 2){
              Navigator.pushNamed(context, '/map_clinic');
            }
          },
        ),
      ),
    );
  }
}