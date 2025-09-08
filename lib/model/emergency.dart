import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String type;
  final String? location;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.location,
  });

  factory EmergencyContact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyContact(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      phone: data['phone'] ?? '',
      type: data['type'] ?? 'Emergency',
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'type': type,
      'location': location,
    };
  }
}