import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/model/appointment_model.dart';
import 'package:nubmed/utils/currentUserInfo.dart';
import 'package:intl/intl.dart';

class PrescriptionsTab extends StatefulWidget {
  const PrescriptionsTab({super.key});

  @override
  State<PrescriptionsTab> createState() => _PrescriptionsTabState();
}

class _PrescriptionsTabState extends State<PrescriptionsTab> {

  List<Appointment> listOfPrescriptions = [];
  bool _isLoading = true;

  Future<void> _fetchPrescriptions() async {
    try {
      final data = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: CurrentUserInfo.uid)
          .where('visited', isEqualTo: true)
          .orderBy('appointmentDate', descending: true)
          .get();

      setState(() {
        listOfPrescriptions = data.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching prescriptions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPrescriptionImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // Image Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    const Text(
                      'Medical Prescription',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                                  SizedBox(height: 8),
                                  Text('Failed to load prescription'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Close Button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (listOfPrescriptions.isEmpty) {
      return const Center(
        child: Text(
          'No prescriptions found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listOfPrescriptions.length,
      itemBuilder: (context, index) {
        final appointment = listOfPrescriptions[index];
        final formattedDate = appointment.appointmentDate != null
            ? DateFormat('MMM dd, yyyy').format(appointment.appointmentDate!)
            : 'Date not available';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Name
                Text(
                  'Doctor: ${appointment.doctorName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Doctor Specialization (if available)
                if (appointment.doctorSpecialization != null && appointment.doctorSpecialization!.isNotEmpty)
                  Text(
                    'Specialization: ${appointment.doctorSpecialization}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                const SizedBox(height: 8),

                // Appointment Date
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 8),

                // Visiting Time (if available)
                if (appointment.visitingTime != null && appointment.visitingTime!.isNotEmpty)
                  Text(
                    'Time: ${appointment.visitingTime}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                const SizedBox(height: 16),

                // View Prescription Button
                if (appointment.prescription != null && appointment.prescription!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showPrescriptionImage(appointment.prescription!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('View Prescription'),
                        ],
                      ),
                    ),
                  )
                else
                  const Text(
                    'No prescription available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}