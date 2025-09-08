import 'package:cloud_firestore/cloud_firestore.dart';

class LabTest_Model {
  final String id;
  final String name;
  final String category;
  final double price;
  final String sampleType;
  final String preparation;
  final String description;
  final Map<String, String> normalRanges;
  final int turnaroundTime; // in hours
  final bool isActive;

  LabTest_Model({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.sampleType,
    this.preparation = "No special preparation",
    this.description = "",
    required this.normalRanges,
    this.turnaroundTime = 24,
    this.isActive = true,
  });

  // Convert Firestore document to LabTest object
  factory LabTest_Model.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LabTest_Model(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Test',
      category: data['category'] ?? 'General',
      price: (data['price'] ?? 0.0).toDouble(),
      sampleType: data['sampleType'] ?? 'Blood',
      preparation: data['preparation'] ?? 'No special preparation',
      description: data['description'] ?? '',
      normalRanges: Map<String, String>.from(data['normalRanges'] ?? {}),
      turnaroundTime: data['turnaroundTime'] ?? 24,
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert LabTest object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'sampleType': sampleType,
      'preparation': preparation,
      'description': description,
      'normalRanges': normalRanges,
      'turnaroundTime': turnaroundTime,
      'isActive': isActive,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Helper method to display price with currency
  String get formattedPrice => '৳${price.toStringAsFixed(2)}';

  // Helper method to display turnaround time
  String get formattedTurnaround {
    if (turnaroundTime < 24) return '$turnaroundTime hours';
    if (turnaroundTime == 24) return '1 day';
    return '${turnaroundTime ~/ 24} days';
  }
}