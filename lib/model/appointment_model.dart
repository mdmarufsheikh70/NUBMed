import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final DateTime appointmentDate;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization; // Added field
  final DateTime? processedAt;
  final String? processedBy;
  final int serialNumber;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String prescription;
  final String userPhone; // Added field
  final String userStudentId; // Added field
  final bool visited;
  final String visitingTime;


  Appointment({
    required this.id,
    required this.appointmentDate,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    this.processedAt,
    this.processedBy,
    required this.serialNumber,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userStudentId,
    required this.visited,
    required this.visitingTime,
    required this.prescription,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialization: data['doctorSpecialization'] ?? '',
      processedAt: data['processedAt'] != null
          ? (data['processedAt'] as Timestamp).toDate()
          : null,
      processedBy: data['processedBy'],
      serialNumber: data['serialNumber'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      userStudentId: data['userStudentId'] ?? '',
      visited: data['visited'] ?? false,
      visitingTime: data['visitingTime'] ?? '',
      prescription: data['prescription']??'',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'processedBy': processedBy,
      'serialNumber': serialNumber,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userStudentId': userStudentId,
      'visited': visited,
      'visitingTime': visitingTime,
      'prescription':prescription,
    };
  }

  String get formattedAppointmentDate {
    return DateFormat('MMMM d, y').format(appointmentDate);
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(appointmentDate);
  }

  String get formattedProcessedAt {
    return processedAt != null
        ? DateFormat('MMMM d, y h:mm a').format(processedAt!)
        : 'Not processed yet';
  }

  String get formattedTimestamp {
    return DateFormat('MMMM d, y h:mm a').format(timestamp);
  }
}