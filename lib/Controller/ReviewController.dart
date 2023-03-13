
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetclinicapp/Model/reviewModel.dart';

class ApointmentController{
  static final FirebaseAuth firabaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<List<reviewModel>> getClinicReviews(String id) async {
    List<reviewModel> clinic_reviews = [];
    QuerySnapshot clinic_reviews_list = await firestore.collection('clinics').doc(id).collection('reviews').get();
    clinic_reviews_list.docs.forEach((data) { 
      clinic_reviews.add(reviewModel.fromMap(jsonDecode(jsonEncode(data.data()))));
    });
    return clinic_reviews;
  }

}