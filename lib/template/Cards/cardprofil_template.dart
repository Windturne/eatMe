import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class CardProfileTemplate extends StatefulWidget {
  String description;
  Function onTap;

  @override
  _CardProfileTemplateState createState() =>
      _CardProfileTemplateState(this.description, this.onTap);

  CardProfileTemplate(this.description, this.onTap);
}

class _CardProfileTemplateState extends State<CardProfileTemplate> {
  String description;
  Function onTap;

  _CardProfileTemplateState(this.description, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: Card(
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w),
            child: Row(
              children: [
                Text(
                  description,
                  style: descriptionTextBlack12,
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_right_rounded)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
