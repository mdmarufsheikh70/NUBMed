import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String category;
  final String manufacturer;
  final int stock;
  final int minStock;
  final String? genericName;
  final String? uses;
  final String? dosage;
  final String? sideEffects;
  final DateTime? expiry;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.manufacturer,
    required this.stock,
    required this.minStock,
    this.genericName,
    this.uses,
    this.dosage,
    this.sideEffects,
    this.expiry,
  });

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? expiryDate;
    if (data['expiry'] != null) {
      if (data['expiry'] is Timestamp) {
        expiryDate = data['expiry'].toDate();
      } else if (data['expiry'] is String) {
        expiryDate = DateTime.tryParse(data['expiry']);
      }
    }

    return Medicine(
      id: doc.id,
      name: data['name']?.toString() ?? 'Unknown Medicine',
      category: data['category']?.toString() ?? 'Uncategorized',
      manufacturer: data['manufacturer']?.toString() ?? 'N/A',
      stock: int.tryParse(data['stock']?.toString() ?? '0') ?? 0,
      minStock: int.tryParse(data['minStock']?.toString() ?? '10') ?? 10,
      genericName: data['genericName']?.toString(),
      uses: data['uses']?.toString(),
      dosage: data['dosage']?.toString(),
      sideEffects: data['sideEffects']?.toString(),
      expiry: expiryDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'manufacturer': manufacturer,
      'stock': stock,
      'minStock': minStock,
      'genericName': genericName,
      'uses': uses,
      'dosage': dosage,
      'sideEffects': sideEffects,
      'expiry': expiry,
      // Add timestamp for when the record was last updated
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}