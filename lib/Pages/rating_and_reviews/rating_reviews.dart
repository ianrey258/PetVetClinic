import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vetclinicapp/Controller/ReviewController.dart';
import 'package:vetclinicapp/Controller/UserController.dart';
import 'package:vetclinicapp/Model/reviewModel.dart';
import 'package:vetclinicapp/Model/userModel.dart';
import 'package:vetclinicapp/Pages/_helper/image_loader.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';
import 'package:vetclinicapp/Utils/SharedPreferences.dart';

class RatingReviews extends StatefulWidget {
  const RatingReviews({Key? key}) : super(key: key);

  @override
  _RatingReviewsState createState() => _RatingReviewsState();
}

class _RatingReviewsState extends State<RatingReviews> {
  final ScrollController _sc = ScrollController();
  List<TextEditingController> text = [];
  double clinic_rating = 0.0; 
  final _key = GlobalKey<FormState>();
  Map<String,int> clinic_rating_no = {"5":0,"4":0,"3":0,"2":0,"1":0};
  List<Map<String,dynamic>> reviewsList = [];
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
    reviewsList = [];
    final clinic_id = await DataStorage.getData('id');
    clinic_rating = await RatingReviewController.getRatingClinic(clinic_id);
    List clinic_revews_list = await RatingReviewController.getRatingReviewClinicList(clinic_id);
    clinic_revews_list.forEach((clinic_review) async { 
      RatingReviewModel clinic_rev = clinic_review;
      UserModel user_review = await UserController.getUser(clinic_rev.user_id??'');
      setState(() {
        clinic_rating_no[int.parse(clinic_rev.rate.toString().split('.').first).toString()] = clinic_rating_no[clinic_rev.rate??'0']??0 + 1;
        reviewsList.add({
          "user": user_review,
          "review": clinic_rev
        });
      });
    });
  }

  refreshPage(){
    refresh = !refresh;
  }

  Widget displayRatings(){
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(left: 10,right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 50,
              child: Center(
                child: Text('Clinic Ratings',style: TextStyle(fontSize: 25,color: secondaryColor,fontWeight: FontWeight.w500),),
              ),
            )
          ] + clinic_rating_no.keys.map((key) => Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmoothStarRating(
                  starCount: int.parse(key),
                  rating: double.parse(key),
                  color: text6Color,
                ),
                Text(clinic_rating_no[key].toString(),style: TextStyle(color: secondaryColor))
              ],
          )).toList(),
        ),
      ),
    );
  }

  Widget clinicReviewsItem(UserModel? user,RatingReviewModel? review){
    return ListTile(
      contentPadding: EdgeInsets.all(5),
      style: ListTileStyle.list,
      leading: user?.profile_img != "" ? ImageLoader.loadImageNetwork(user?.profile_img??"",50.0,50.0) : FaIcon(FontAwesomeIcons.user,size: 50),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(user?.fullname??""),
          Text(DateFormat.yMd().format(DateTime.parse(review?.datatime??""))),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(review?.comment??""),
          SmoothStarRating(
            starCount: 5,
            rating: double.parse(review?.rate??'0.0'),
            color: text6Color,
          ),
        ],
      ),
    );
  }

  List<Widget> reviewList(){
    if(reviewsList!.isEmpty){
      return [Center(child: Text("No Rate Yet"),)];
    }
    return [displayRatings()] + reviewsList.map((_user_review) => clinicReviewsItem(_user_review['user'],_user_review['review'])).toList();
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
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: RefreshIndicator(
            onRefresh: ()=>initLoadData(),
            child: ListView(
              children: reviewList(),
            ),
          ),
        ),
      ),
    );
  }
}
