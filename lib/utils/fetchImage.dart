import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchImage {
  static Future<String?> fetchImageUrl(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        return doc.data()?["photo_url"] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching image URL: $e');
      return null;
    }
  }
}