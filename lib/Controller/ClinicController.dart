
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetclinicapp/Controller/FileController.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Services/firebase_messaging.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ClinicController{
  static final FirebaseAuth firabaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static verifyClinic(List<TextEditingController> data) async {
    try{
      UserCredential fb_auth = await firabaseAuth.signInWithEmailAndPassword(email: data[0].value.text.toString().toLowerCase(), password: data[1].value.text.toString());
      if(!await isInEmail(data[0].value.text.toString().toLowerCase())){
        return false;
      }
      return true;
    }catch(e){
      debugPrint("Error on: ${e.toString()}");
      return false;
    }
  }
  
  static loginClinic(List<TextEditingController> data) async {
    try{
      UserCredential fb_auth = await firabaseAuth.signInWithEmailAndPassword(email: data[0].value.text.toString().toLowerCase(), password: data[1].value.text.toString());
      await DataStorage.setData('email', data[0].value.text.toString().toLowerCase());
      DocumentSnapshot user_doc = await firestore.collection('clinics').doc(fb_auth.user?.uid??"").get();
      ClinicModel clinic = ClinicModel.fromMap(jsonDecode(jsonEncode(user_doc.data())));

      await checkClinicFCMToken(clinic);
      await DataStorage.setData('id', clinic.id);
      await DataStorage.setData('username',clinic.clinic_doctor);
      await DataStorage.setData('fullname',clinic.clinic_doctor);
      await DataStorage.setData('email',clinic.clinic_email);
      return true;
    }catch(e){
      debugPrint("Error on: ${e.toString()}");
      return false;
    }
  }
  
  static registerClinic(List<TextEditingController> data) async {
    UserCredential fb_auth;
    try{
      fb_auth = await firabaseAuth.createUserWithEmailAndPassword(email: data[2].value.text.toString().toLowerCase(), password: data[4].value.text.toString());
    }catch(e){
      fb_auth = await firabaseAuth.signInWithEmailAndPassword(email: data[2].value.text.toString().toLowerCase(), password: data[4].value.text.toString());
    }
    try{
      data[5].text = await setClinicLogo(data[5].text,fb_auth.user?.uid??"",); 
      data[6].text = await setClinicBanner(data[6].text,fb_auth.user?.uid??"",); 
    } catch(e){
      debugPrint('Error File input');
    }
    try{
      DocumentReference clinic_table = firestore.collection('clinics').doc(fb_auth.user?.uid??"");
      print(json.decode(data[9].text,reviver: (key, value) => value.toString()));
      List<dynamic> dyn_services = json.decode(data[9].text).map((data) => data.toString()).toList();
      List<String> services = dyn_services.map((data) => data.toString()).toList();
      print(services);
      ClinicModel clinic = ClinicModel(
                          fb_auth.user?.uid??"", 
                          data[0].value.text.toString(), 
                          data[1].value.text.toString(), 
                          data[2].value.text.toString(),
                          data[3].value.text.toString(),
                          data[5].value.text.toString(),
                          data[6].value.text.toString(),
                          data[7].value.text.toString(),
                          data[8].value.text.toString(),
                          "0",
                          services,
                          []
                        );
      await updateClinic(clinic);
      await DataStorage.setData('id', clinic.id);
      await DataStorage.setData('username',clinic.clinic_doctor);
      await DataStorage.setData('fullname',clinic.clinic_doctor);
      await DataStorage.setData('email',clinic.clinic_email);
      return true;
    }catch(e){
      debugPrint("Error on ${e.toString()}");
      return false;
    }
  }
  
  // static updateClinicProfile(List<TextEditingController> data) async {
  //   try{
  //     final user_id = await DataStorage.getData('id');
  //     DocumentSnapshot clinic_doc = await firestore.collection('clinics').doc(user_id).get();
  //     ClinicModel clinic = ClinicModel.fromMap(jsonDecode(jsonEncode(clinic_doc.data())));
  //     clinic.clinic_name = data[0].value.text.toString();
  //     clinic.clinic_doctor = data[1].value.text.toString();
  //     clinic.clinic_email = data[2].value.text.toString();
  //     clinic.clinic_address = data[3].value.text.toString();
  //     updateClinic(clinic);
  //     await DataStorage.setData('id', clinic.id);
  //     await DataStorage.setData('username',clinic.clinic_doctor);
  //     await DataStorage.setData('fullname',clinic.clinic_doctor);
  //     await DataStorage.setData('email',clinic.clinic_email);
  //     return true;
  //   }catch(e){
  //     debugPrint("Error on ${e.toString()}");
  //     return false;
  //   }
  // }

  static Future<ClinicModel> getClinic(String id) async {
    DocumentSnapshot clinic_doc = await firestore.collection('clinics').doc(id).get();
    ClinicModel clinic = ClinicModel.fromMap(jsonDecode(jsonEncode(clinic_doc.data())));
    return clinic;
  }
  
  static Future<void> sendResetPassword(String email) async {
    var fb_auth = await firabaseAuth.sendPasswordResetEmail(email: email);
  }

  static Future<bool> sendChangeEmail(String email) async {
    try{
      // var fb_auth = await EmailAuthProvider.credential(email);
      // var fb_auth = await firabaseAuth.currentUser?.reauthenticateWithCredential(email);
      await firabaseAuth.currentUser?.updateEmail(email);
      await firabaseAuth.currentUser!.sendEmailVerification();
      return true;
    }catch(e){
      return false;
    }
  }

  static Future<bool> isInEmail(String email) async {
    try{
      CollectionReference clinic_table = await firestore.collection('clinics');
      QuerySnapshot clinic = await clinic_table.where('clinic_email',isEqualTo: email).get();
      if(clinic.docs.isEmpty){
        return false;
      }
      return true;

    }catch(e){
      return true;
    }
  }
  
  static Future<bool> updateClinic(ClinicModel data) async {
    try{
      DocumentReference clinic_table = await firestore.collection('clinics').doc(data?.id);
      ClinicModel? clinic = data;
      if(!clinic.clinic_img!.contains(clinic.id!)){
        clinic.clinic_img = await updateClinicLogo(clinic.clinic_img!);
      }
      if(!clinic.clinic_img_banner!.contains(clinic.id!)){
        clinic.clinic_img_banner = await updateClinicBanner(clinic.clinic_img_banner!);
      }
      clinic_table.set(clinic.toMap());
      return true;
    }catch(e){
      debugPrint("Error on: ${e.toString()}");
      return false;
    }
  }

  static Future<String> setClinicLogo(String file_path,[clinic_id = "junk"]) async {
    String filename = file_path.split('/').last;
    String final_path = "/${clinic_id??''}/logo/${filename}";
    await FileController.setFile(final_path, file_path);
    return final_path;
  }
  
  static Future<String> setClinicBanner(String file_path,[clinic_id = "junk"]) async {
    String filename = file_path.split('/').last;
    String final_path = "/${clinic_id??''}/banner/${filename}";
    await FileController.setFile(final_path, file_path);
    return final_path;
  }

  static Future checkClinicFCMToken(ClinicModel clinic) async {
    //check fcm tokens
      List fcm_tokens = clinic.fcm_tokens??[];
      String device_fcm_token = await FirebaseMessagingService.getFCMToken();
      if(!fcm_tokens.contains(device_fcm_token)){
        clinic.fcm_tokens = fcm_tokens + [device_fcm_token];
        await updateClinic(clinic);
      }
  }
  
  static Future<String> updateClinicLogo(String file_path) async {
    final clinic_id = await DataStorage.getData('id');
    String filename = file_path.split('/').last;
    String final_path = "/${clinic_id??''}/logo/${filename}";
    await FileController.setFile(final_path, file_path);
    ClinicModel clinic = await getClinic(clinic_id);
    if(clinic.clinic_img != ""){
      FileController.removeFile(clinic.clinic_img??"");
    }
    clinic.clinic_img = final_path;
    await updateClinic(clinic);
    return final_path;
  }
  
  static Future<String> updateClinicBanner(String file_path) async {
    final clinic_id = await DataStorage.getData('id');
    String filename = file_path.split('/').last;
    String final_path = "/${clinic_id??''}/banner/${filename}";
    await FileController.setFile(final_path, file_path);
    ClinicModel clinic = await getClinic(clinic_id);
    if(clinic.clinic_img_banner != ""){
      FileController.removeFile(clinic.clinic_img_banner??"");
    }
    clinic.clinic_img = final_path;
    await updateClinic(clinic);
    return final_path;
  }
  
  static logoutClinic() async {
    try{
      await FirebaseAuth.instance.signOut();
      await DataStorage.clearStorage();
      return true;
    }catch(e){
      debugPrint("Error on: ${e.toString()}");
      return false;
    }
  }

}