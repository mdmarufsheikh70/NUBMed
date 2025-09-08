import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context,String content,bool isError){
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(content),backgroundColor: isError?Colors.red:Colors.green,behavior: SnackBarBehavior.floating,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(10),
       ),),
   );
}