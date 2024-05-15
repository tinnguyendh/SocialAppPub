import 'package:flutter/material.dart';

class PassFieldInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final TextInputType textInputType;
  const PassFieldInput(
      {Key? key,
      required this.textEditingController,
      required this.hintText,
      required this.textInputType})
      : super(key: key);

  @override
  State<PassFieldInput> createState() => _PassFieldInputState();
}

class _PassFieldInputState extends State<PassFieldInput> {
  bool isPass = true;

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextField(
      controller: widget.textEditingController,
      decoration: InputDecoration(
          hintText: widget.hintText,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          filled: true,
          contentPadding: const EdgeInsets.all(8),
          suffixIcon: IconButton(
            icon: Icon(
              isPass ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                isPass = !isPass;
              });
            },
          )),
      keyboardType: widget.textInputType,
      obscureText: isPass,
    );
  }
}
