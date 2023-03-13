
import 'package:flutter/material.dart';
import 'package:vetclinicapp/Style/_custom_color.dart';

ButtonStyle buttonStyleA(double width,double hieght,double radius,Color color){
  return ButtonStyle(
    fixedSize: MaterialStateProperty.all(Size(width, hieght)),
    backgroundColor: MaterialStateProperty.all(color),
    shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius)
      )
    )
  );
}

ButtonStyle outlineButtonStyleA(double width,double hieght,double radius,Color color){
  return ButtonStyle(
    fixedSize: MaterialStateProperty.all(Size(width, hieght)),
    backgroundColor: MaterialStateProperty.all(color),
    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
    shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: color)
      )
    )
  );
}