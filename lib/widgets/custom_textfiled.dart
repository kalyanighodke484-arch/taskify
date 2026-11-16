import 'package:flutter/material.dart';

class AppTextFiled{
  static InputDecoration mDecoration({
    required String label,
    required String hint,
    IconData? mIcons,
    bool isPass=false,
    bool isPasswordVisible=false,
    void Function()? onObscureTap
  }){
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: isPass?InkWell(
          onTap: onObscureTap,
          child: Icon(isPasswordVisible?Icons.visibility:Icons.visibility_off)):null,
      prefixIcon:mIcons !=null? Icon(mIcons):null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13)
      ),enabledBorder:OutlineInputBorder(
        borderRadius: BorderRadius.circular(13)
    ),
    );
  }
}