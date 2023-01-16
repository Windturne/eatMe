import 'dart:ui';

import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class TextFieldTemplate extends StatefulWidget {
  String hintText;
  bool isPassword;
  bool isNumber;
  TextEditingController textController = new TextEditingController();
  TextFieldTemplate(
      this.hintText, this.isPassword, this.isNumber, this.textController);

  @override
  _TextFieldTemplateState createState() => _TextFieldTemplateState(
      this.hintText, this.isPassword, this.isNumber, this.textController);
}

class _TextFieldTemplateState extends State<TextFieldTemplate> {
  String hintText;
  bool isPassword;
  bool isNumber;
  TextEditingController textController = new TextEditingController();
  _TextFieldTemplateState(
      this.hintText, this.isPassword, this.isNumber, this.textController);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      style:
          TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: black),
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
    );
  }
}
