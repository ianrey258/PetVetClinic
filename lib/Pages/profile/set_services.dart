import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Model/clinicModel.dart';
import 'package:vetclinicapp/Style/library_style_and_constant.dart';

class SetServices extends StatefulWidget {
  final List<String>? services;
  const SetServices({Key? key,this.services}) : super(key: key);

  @override
  _SetServices createState() => _SetServices();
}

class _SetServices extends State<SetServices> {
  final ScrollController _sc = ScrollController();
  List<TextEditingController> text = [];
  final _key = GlobalKey<FormState>();
  List<String> selectedServices = [];

  @override
  initState() {
    super.initState();
    setState(() {
      for (int i = 0; i < 10; i++) {
        text.add(TextEditingController());
      }
    });
  }

  updateServices(String service){
    setState(() {
      selectedServices.contains(service) ? selectedServices.remove(service) : selectedServices.add(service);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    setState(() {
      selectedServices = widget.services!;
    });

    return AlertDialog(
      title: Text('Select Services'),
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          child: Wrap(
            children: ClinicService.getSampleServices().map((ClinicService service)=>Padding(
              padding:EdgeInsets.all(2.0),
              child: FilterChip(
                backgroundColor: backgroundColor,
                side: BorderSide(color: secondaryColor,),
                label: Text(service.name??"",style: TextStyle(color: selectedServices.contains(service.name) ? text1Color : text2Color,fontSize: 10),),
                selected: selectedServices.contains(service.name),
                selectedColor: secondaryColor,
                onSelected: (value){
                  updateServices(service.name??"");
                },
              ) 
            )).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text("Cancel")
        ),
        TextButton(
          onPressed: (){
            Navigator.pop(context,selectedServices);
          }, 
          child: Text("Ok")
        )
      ],
    );
  }
}
