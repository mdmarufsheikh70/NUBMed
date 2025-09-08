import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nubmed/model/user_model.dart';

class CurrentUserInfo{
  static medUser? currentuser;
  static final uid = FirebaseAuth.instance.currentUser!.uid;
  static Future<void> fectch_currentUser()async{
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    currentuser = medUser.fromFirestore(snapshot);
  }
}