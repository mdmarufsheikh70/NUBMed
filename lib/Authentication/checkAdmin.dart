import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class Administrator{
  static bool _admin = false;
  static bool _moderator = false;
  static Future<void> isAdmin(String email)async{
    final doc =await FirebaseFirestore.instance.collection('admins').doc(email).get();
    _admin = doc.exists;
  }
  static Future<void> isModerator(String email)async{
    final doc =await FirebaseFirestore.instance.collection('moderators').doc(email).get();
    _moderator = doc.exists;
  }

  static bool get isAdminUser => _admin;
  static bool get isModeratorUser => _moderator;
}