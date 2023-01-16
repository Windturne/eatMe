import 'package:eatme_mobileapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class OutlinedButtonTemplate extends StatefulWidget {
  Color colorInput;
  IconData iconInput;
  String textButton;
  final GestureTapCallback onPressed;

  @override
  _OutlinedButtonTemplateState createState() => _OutlinedButtonTemplateState(
      this.colorInput, this.iconInput, this.textButton,
      onPressed: onPressed);

  OutlinedButtonTemplate(this.colorInput, this.iconInput, this.textButton,
      {@required this.onPressed});
}

class _OutlinedButtonTemplateState extends State<OutlinedButtonTemplate> {
  Color colorInput;
  IconData iconInput;
  String textButton;
  final GestureTapCallback onPressed;

  _OutlinedButtonTemplateState(this.colorInput, this.iconInput, this.textButton,
      {@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(
        iconInput,
        color: colorInput,
        // size: 20,
      ),
      label: Text(textButton, style: descriptionTextGrey12),
      onPressed: onPressed,
      style: TextButton.styleFrom(
          // minimumSize: Size.zero,
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 15.w)
          // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
    );
  }
}
