import 'package:flutter/material.dart';

// ignore: must_be_immutable
class IconButtonTemplate extends StatefulWidget {
  Color colorInput;
  IconData iconInput;
  final GestureTapCallback onPressed;

  @override
  _IconButtonTemplateState createState() =>
      _IconButtonTemplateState(this.colorInput, this.iconInput,
          onPressed: onPressed);

  IconButtonTemplate(this.colorInput, this.iconInput,
      {@required this.onPressed});
}

class _IconButtonTemplateState extends State<IconButtonTemplate> {
  Color colorInput;
  IconData iconInput;
  final GestureTapCallback onPressed;

  _IconButtonTemplateState(this.colorInput, this.iconInput,
      {@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        iconInput,
        color: colorInput,
      ),
      label: Text(''),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
