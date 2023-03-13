
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vetclinicapp/Controller/FileController.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserController{
  static final FirebaseAuth firabaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage firebaseStorage= FirebaseStorage.instance;

  static Future<UserModel> getUser(String id) async {
    DocumentSnapshot user_doc = await firestore.collection('users').doc(id).get();
    UserModel user = UserModel.fromMap(jsonDecode(jsonEncode(user_doc.data())));
    return user;
  }

}