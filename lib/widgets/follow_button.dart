import 'package:flutter/material.dart';

class FollowButon extends StatelessWidget {
  const FollowButon({
    Key? key,
    this.function,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.text,
  }) : super(key: key);

  final Function()? function;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      child: TextButton(
        onPressed: function,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          width: 250,
          height: 35,
        ),
      ),
    );
  }
}
