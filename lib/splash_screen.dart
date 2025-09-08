
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubmed/Authentication/Sign_in.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/Update%20Checker/check_update.dart';
import 'package:nubmed/WidgetTree.dart';
import 'package:nubmed/Widgets/screen_background.dart';
import 'package:nubmed/utils/fcm_service.dart';
import 'package:nubmed/utils/specialization_list.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static String name = '/splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  Future<void> _navigateBasedOnAuth() async {
    bool updated = await UpdateChecker(context).checkForUpdate();
    if (updated) {
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final currentUser = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final token = await FCMService().getFcmToken();

      if (!currentUser.data()!.containsKey('fcm_token') && token != null) {
        await currentUser.reference.update({
          'fcm_token': FieldValue.arrayUnion([token])
        });
      }

      await Administrator.isAdmin(user.email!);
      await Administrator.isModerator(user.email!);
      await Specialization.fetchSpecialization();

      Navigator.pushNamedAndRemoveUntil(
          context, WidgetTree.name, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, Signinscreen.name, (route) => false);
    }
  }


  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuth();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Center(
        child:Image.asset("assets/NUBMED_logo.png",height: 300,width: 400,)
        ),

    );
  }
}
