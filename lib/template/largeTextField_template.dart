import 'dart:ui';

import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class LargeTextFieldTemplate extends StatefulWidget {
  String hintText;
  bool isPassword;
  TextEditingController textController = new TextEditingController();
  LargeTextFieldTemplate(this.hintText, this.isPassword, this.textController);

  @override
  _LargeTextFieldTemplateState createState() => _LargeTextFieldTemplateState(
      this.hintText, this.isPassword, this.textController);
}

class _LargeTextFieldTemplateState extends State<LargeTextFieldTemplate> {
  String hintText;
  bool isPassword;
  TextEditingController textController = new TextEditingController();
  _LargeTextFieldTemplateState(
      this.hintText, this.isPassword, this.textController);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      child: TextField(
        maxLines: 5,
        controller: textController,
        style: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.w400, color: black),
        obscureText: isPassword,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: lightGrey, width: 1.w)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: lightGrey, width: 1.w)),
            filled: false,
            hintText: hintText,
            hintStyle: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w400, color: darkGrey),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h)),
      ),
    );
  }
}
