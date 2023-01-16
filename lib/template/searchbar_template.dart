import 'dart:ui';

import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class SearchBarTemplate extends StatefulWidget {
  String hintText;
  bool isPassword;
  ValueChanged<String> onChanged;
  TextEditingController textController = new TextEditingController();
  SearchBarTemplate(
      this.hintText, this.isPassword, this.onChanged, this.textController);

  @override
  _SearchBarTemplateState createState() => _SearchBarTemplateState(
      this.hintText, this.isPassword, this.onChanged, this.textController);
}

class _SearchBarTemplateState extends State<SearchBarTemplate> {
  String hintText;
  bool isPassword;
  ValueChanged<String> onChanged;
  TextEditingController textController = new TextEditingController();
  _SearchBarTemplateState(
      this.hintText, this.isPassword, this.onChanged, this.textController);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      style:
          TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: black),
      obscureText: isPassword,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
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
      onChanged: onChanged,
    );
  }
}
