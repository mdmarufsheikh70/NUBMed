
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nubmed/Authentication/Sign_in.dart';
import 'package:nubmed/Authentication/forget_password.dart';
import 'package:nubmed/Authentication/sign_up_screen.dart';
import 'package:nubmed/WidgetTree.dart';
import 'package:nubmed/pages/Admin_Pages/AdminHealthTipsPage.dart';
import 'package:nubmed/pages/Admin_Pages/AdminMedicine.dart';
import 'package:nubmed/pages/Admin_Pages/addOrUpdate_doctor.dart';

import 'package:nubmed/pages/Admin_Pages/available_doctor_list.dart';
import 'package:nubmed/pages/Doctor/Doctor_Page.dart';
import 'package:nubmed/pages/HomePage.dart';
import 'package:nubmed/pages/Emergency/emergency.dart';
import 'package:nubmed/pages/Health%20Tips/health_tips.dart';
import 'package:nubmed/pages/Medicine/medicine_page.dart';
import 'package:nubmed/splash_screen.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/fcm_service.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ This is required for web!
  );
  await FCMService().initialize();
  runApp(NUBMED());
}

class NUBMED extends StatelessWidget {
  const NUBMED({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: "NUBMED",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color_codes.middle_plus,primary: Color_codes.meddle),
          appBarTheme: AppBarTheme(
            color: Color_codes.meddle,
            shadowColor: Colors.black,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 22, // use .sp
              fontWeight: FontWeight.w700,
            ),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            TextTheme(
              titleLarge: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10), // .r for radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              fixedSize: Size.fromWidth(double.maxFinite),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Color_codes.meddle,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          Signinscreen.name: (context) => Signinscreen(),
          Homepage.name: (context) => Homepage(),
          DoctorPage.name: (context) => DoctorPage(),
          WidgetTree.name: (context) => WidgetTree(),
          SignUpScreen.name: (context) => SignUpScreen(),
          MedicinePage.name: (context) => MedicinePage(),
          HealthTips.name: (context) => HealthTips(),
          AdminMedicinePage.name: (context) => AdminMedicinePage(),
          AdminHealthTipsPage.name: (context) => AdminHealthTipsPage(),
          AdminHealthTipsPage.name: (context) => AdminHealthTipsPage(),
          AddOrUpdateNewDoctor.name:(context)=>AddOrUpdateNewDoctor(),
          AvailableDoctorList.name:(context)=>AvailableDoctorList(),
          EmergencyScreen.name:(context)=>EmergencyScreen(),
          ForgetPassword.name:(context)=>ForgetPassword(),
        },
      ),
    );
  }
}

