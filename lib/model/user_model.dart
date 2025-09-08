import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class medUser {
  final String id;
  final String bloodGroup;
  final bool donor;
  final String email;
  final String location;
  final String name;
  final String phone;
  final String photoUrl;
  final String studentId;
  final List<String> fcmToken;

  medUser({
    required this.id,
    required this.bloodGroup,
    required this.donor,
    required this.email,
    required this.location,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.studentId,
    required this.fcmToken,
  });

  factory medUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return medUser(
      id: doc.id,
      bloodGroup: data['blood_group'] ?? '',
      donor: data['donor'] ?? false,
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      studentId: data['student_id'] ?? '',
      fcmToken: data['fcm_token'] !=null? List<String>.from(data['fcm_token']):[]
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'blood_group': bloodGroup,
      'donor': donor,
      'email': email,
      'location': location,
      'name': name,
      'phone': phone,
      'photo_url': photoUrl,
      'student_id': studentId,
      'fcm_token':fcmToken,
    };
  }
  factory medUser.fromMap(Map<String, dynamic> data, String id) {
    return medUser(
      id: id,
      bloodGroup: data['blood_group'] ?? '',
      donor: data['donor'] ?? false,
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      studentId: data['student_id'] ?? '',
      fcmToken: data['fcmTokens'] != null
          ? List<String>.from(data['fcmTokens'])
          : [],
    );
  }

}