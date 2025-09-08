
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/Authentication/forget_password.dart';
import 'package:nubmed/Authentication/sign_up_screen.dart';
import 'package:nubmed/WidgetTree.dart';
import 'package:nubmed/Widgets/screen_background.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/utils/Color_codes.dart';


class Signinscreen extends StatefulWidget {
   const Signinscreen({super.key});

  static const String name  = '/sign-in';


  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    "Get Started With",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailTEController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: "Email"),

                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordTEController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(hintText: "Password"),
                    validator: (String? value){
                      if((value?.length ?? 0) <6){
                        return 'Enter a valid password';
                      }
                      return null;
                    },

                  ),
                  const SizedBox(height: 16),

                  Visibility(
                    visible: isLoading == false,
                    replacement: Center(child: CircularProgressIndicator(),),
                    child: FilledButton(
                      onPressed: _onTapSignInButton,
                      child: Text("Sign in"),
                    ),
                  ),
                  SignUpScreen.emailSent ? Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Account activation email sent!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ve sent an activation link to your email address.\n'
                            'Please check your inbox and spam folder if you don\'t see it within a few minutes.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ) : const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: _onTapForgotPasswordButton,
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Don't have an account?  ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.4,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Color_codes.meddle,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _onTapSignUpButton,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future _onTapSignInButton()async{
    setState(() {
      isLoading = true;
    });
    if(_formKey.currentState!.validate()){
      try{
        await Administrator.isAdmin(_emailTEController.text);
        await Administrator.isModerator(_emailTEController.text);
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailTEController.text, password: _passwordTEController.text);

        User? user = FirebaseAuth.instance.currentUser;
        final token = await FirebaseMessaging.instance.getToken();
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'fcm_token':FieldValue.arrayUnion([token])});
        
        if(!user.emailVerified){
          user.sendEmailVerification();
          await FirebaseAuth.instance.signOut();
          showSnackBar(context, "Please verify your email before signing in", true);
          setState(() {
            isLoading = false;
          });
          return;
        }

        Navigator.pushNamedAndRemoveUntil(context, WidgetTree.name, (predicate)=>false);
      } on FirebaseAuthException catch (e){
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, "Login Failed", true);
      }
    }else{
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onTapSignUpButton() {
    Navigator.pushNamed(context, SignUpScreen.name);
  }

  void _onTapForgotPasswordButton() {
    Navigator.pushNamed(context, ForgetPassword.name);
  }
}
