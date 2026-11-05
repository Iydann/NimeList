import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}
