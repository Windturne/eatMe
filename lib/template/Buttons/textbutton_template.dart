import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class TextButtonTemplate extends StatefulWidget {
  String textButton;
  Color btnColor;
  final GestureTapCallback onPressed;

  @override
  _TextButtonTemplateState createState() =>
      _TextButtonTemplateState(this.textButton, this.btnColor,
          onPressed: onPressed);

  TextButtonTemplate(this.textButton, this.btnColor,
      {@required this.onPressed});
}

class _TextButtonTemplateState extends State<TextButtonTemplate> {
  String textButton;
  final GestureTapCallback onPressed;
  Color btnColor;

  _TextButtonTemplateState(this.textButton, this.btnColor,
      {@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Text(textButton,
            style: TextStyle(
                color: btnColor,
                fontWeight: FontWeight.w400,
                fontSize: 12.w,
                decoration: TextDecoration.underline)),
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed);
  }
}
