import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class ButtonTemplate extends StatefulWidget {
  String textButton;
  Color btnColor;
  final GestureTapCallback onPressed;

  @override
  _ButtonTemplateState createState() =>
      _ButtonTemplateState(this.textButton, this.btnColor,
          onPressed: onPressed);
  ButtonTemplate(this.textButton, this.btnColor, {@required this.onPressed});
}

class _ButtonTemplateState extends State<ButtonTemplate> {
  String textButton;
  Color btnColor;
  final GestureTapCallback onPressed;

  _ButtonTemplateState(this.textButton, this.btnColor,
      {@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          child: Text(
            textButton,
            style: buttonText,
          ),
          style: ElevatedButton.styleFrom(
              primary: btnColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              padding: EdgeInsets.symmetric(vertical: 10.h)),
          onPressed: onPressed),
    );
  }
}
