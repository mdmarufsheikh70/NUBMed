import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/model/appointment_model.dart';
import 'package:nubmed/utils/Color_codes.dart';

class Appointmentpage extends StatefulWidget {
  const Appointmentpage({super.key});

  @override
  State<Appointmentpage> createState() => _AppointmentpageState();
}

class _AppointmentpageState extends State<Appointmentpage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Appointments")),
        body: const Center(child: Text("Please login first.")),
      );
    }

    final Stream<QuerySnapshot> userAppointments = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: currentUser.uid).where('visited',isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userAppointments,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("Firestore Error: ${snapshot.error}");
            return const Center(child: Text('Something went wrong!'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No appointments yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final appointment = Appointment.fromFirestore(docs[index]);
              final isOver = isAppointmentOver(appointment.appointmentDate);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctorName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Date: ${appointment.formattedAppointmentDate}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              'Time: ${appointment.visitingTime}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            if (appointment.doctorSpecialization.isNotEmpty)
                              Text(
                                'Specialization: ${appointment.doctorSpecialization}',
                                style: const TextStyle(fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Serial: ${appointment.serialNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: isOver
                                  ? Color_codes.deep_plus
                                  : Color_codes.meddle,
                            ),
                            onPressed: isOver
                                ? () async {
                              await _deleteAppointment(appointment.id);
                            }
                                : () {
                              _cancelAppointment(appointment);
                            },
                            child: Text(isOver ? "Delete" : "Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool isAppointmentOver(DateTime appointmentDate) {
    try {
      final appointmentDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return appointmentDay.isBefore(today);
    } catch (e) {
      debugPrint("Error checking appointment date: $e");
      return false;
    }
  }

  Future<void> _deleteAppointment(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .delete();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error deleting appointment: $e");
    }
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    try {
      // First delete the appointment
      await _deleteAppointment(appointment.id);

      // Then update serial numbers for later appointments
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('appointmentDate', isEqualTo: appointment.appointmentDate)
          .where('doctorName', isEqualTo: appointment.doctorName)
          .where('serialNumber', isGreaterThan: appointment.serialNumber)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'serialNumber': doc['serialNumber'] - 1,
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error canceling appointment: $e");
    }
  }
}