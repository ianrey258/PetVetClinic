// ignore_for_file: prefer_const_constructors

import 'package:face_camera/face_camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vetclinicapp/Pages/LoadingScreen/LoadingScreen.dart';
import 'package:vetclinicapp/Pages/apointment/apointmets.dart';
import 'package:vetclinicapp/Pages/apointment/show_appointment.dart';
import 'package:vetclinicapp/Pages/apointment/video_call.dart';
import 'package:vetclinicapp/Pages/apointment/message.dart';
import 'package:vetclinicapp/Pages/dashboard/dashboard.dart';
import 'package:vetclinicapp/Pages/forgot_password/forgot_password.dart';
import 'package:vetclinicapp/Pages/forgot_password/reset_password.dart';
import 'package:vetclinicapp/Pages/login/login.dart';
import 'package:vetclinicapp/Pages/notification/notifications.dart';
import 'package:vetclinicapp/Pages/notification/show_appointment_notif.dart';
import 'package:vetclinicapp/Pages/profile/clinic_profile.dart';
import 'package:vetclinicapp/Pages/register/register1.dart';
import 'package:vetclinicapp/Pages/register/register2.dart';
import 'package:vetclinicapp/Pages/register/register3.dart';
import 'package:vetclinicapp/Pages/register/register4.dart';
import 'package:vetclinicapp/Style/_custom_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await FaceCamera.initialize(); 
  Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetVet Clinic',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: text1Color),
          bodyText2: TextStyle(color: text1Color),
        ),
        primaryColor: primaryColor,
        scaffoldBackgroundColor: secondaryColor,
        backgroundColor: secondaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: secondaryColor
        ),
        buttonColor: primaryColor,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor:secondaryColor
        )
      ),
      routes: {
        '/login': (context) => const Login(),
        '/register1': (context) => const Register1(),
        '/register2': (context) => const Register2(),
        '/register3': (context) => const Register3(),
        '/register4': (context) => const Register4(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/reset_password': (context) => const ResetPassword(),
        '/dashboard': (context) => const Dashboard(),
        '/message': (context) => const Message(),
        '/video_call': (context) => const VideoCall(),
        '/loading_screen': (context) => const LoadingScreen(),
        '/clinic_profile': (context) => const ClinicProfile(),
        '/notifications': (context) => const Notifications(),
        '/apointments': (context) => const Apointments(),
        '/show_apointment': (context) => const ShowAppointment(),
        '/show_apointment_notif': (context) => const ShowAppointmentNotif(),
      },
      initialRoute: '/loading_screen',
      // home: const LoginPage(),
    );
  }
}
