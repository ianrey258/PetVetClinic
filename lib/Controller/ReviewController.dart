
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetclinicapp/Model/reviewModel.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';

class RatingReviewController{
  static final FirebaseAuth firabaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<RatingReviewModel> getRatingReviewClinic(clinic_id) async {
    try{
      RatingReviewModel? review_clinic;
      String user_id = await DataStorage.getData('id');
      QuerySnapshot _rating_review_list = await firestore.collection('clinics')
                                                     .doc(clinic_id)
                                                     .collection('RatingReview')
                                                     .get();
      _rating_review_list.docs.forEach((doc) { 
        if(doc.get('user_id') == user_id){
          review_clinic = RatingReviewModel.fromMap(jsonDecode(jsonEncode(doc.data())));
        }
      });
      return review_clinic!;
    }catch (e){
      debugPrint("Error on: ${e.toString()}");
      return RatingReviewModel(null,null,null,null,null);
    }
  }
  
  static Future<List> getRatingReviewClinicList(clinic_id) async {
    try{
      List<RatingReviewModel> rating_reviews = [];
      QuerySnapshot _rating_review_list = await firestore.collection('clinics')
                                                     .doc(clinic_id)
                                                     .collection('RatingReview')
                                                     .get();
      _rating_review_list.docs.forEach((doc) { 
        rating_reviews.add(RatingReviewModel.fromMap(jsonDecode(jsonEncode(doc.data()))));
      });
      return rating_reviews;
    }catch (e){
      debugPrint("Error on: ${e.toString()}");
      return [];
    }
  }

  static Future<double> getRatingClinic(clinic_id) async {
    try{
      QuerySnapshot _rating_review_list = await firestore.collection('clinics')
                                                     .doc(clinic_id)
                                                     .collection('RatingReview')
                                                     .get();
      double total_decimal = 0.0;
      double total_decimal_max = _rating_review_list.docs.length * 5;
      double numeric_rating = 5;

      _rating_review_list.docs.forEach((doc) {
        total_decimal += double.parse(doc.get('rate'));
      });
      
      double rating = (total_decimal / total_decimal_max) * numeric_rating;
      return rating > 0 ? rating : 0.0 ;
    }catch (e){
      debugPrint("Error on: ${e.toString()}");
      return 0.0;
    }
  }

}