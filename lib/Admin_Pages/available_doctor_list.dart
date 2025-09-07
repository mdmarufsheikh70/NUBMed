import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/pages/Admin_Pages/patientsAppointments.dart';
import 'package:nubmed/utils/Color_codes.dart';

class AvailableDoctorList extends StatefulWidget {
  const AvailableDoctorList({super.key});
  static String name = '/available-doctor-list';

  @override
  State<AvailableDoctorList> createState() => _AvailableDoctorListState();
}

class _AvailableDoctorListState extends State<AvailableDoctorList> {
  final List<Map<String, dynamic>> _todayAppointments = [];
  final List<Map<String, dynamic>> _allDoctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);

      // Fetch all doctors
      final doctorsSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .get();

      _allDoctors.clear();
      _allDoctors.addAll(doctorsSnapshot.docs.map((doc) => doc.data()));

      // Fetch today's appointments
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('appointmentDate', isGreaterThanOrEqualTo: todayStart)
          .where('appointmentDate', isLessThanOrEqualTo: todayEnd)
          .get();

      _todayAppointments.clear();
      _todayAppointments.addAll(appointmentsSnapshot.docs.map((doc) => doc.data()));

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching data: $e');
    }
  }

  int _getAppointmentCount(String doctorName) {
    return _todayAppointments
        .where((appt) => appt['doctorName'] == doctorName)
        .length;
  }

  bool _isDoctorAvailableToday(Map<String, dynamic> doctor) {
    final today = DateTime.now();
    final todayName = DateFormat('EEEE').format(today);
    final availableDays = List<String>.from(doctor['visiting_days'] ?? []);
    return availableDays.contains(todayName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Available Doctors"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allDoctors.isEmpty
          ? const Center(
        child: Text(
          'No doctors found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _allDoctors[index];
          final isAvailable = _isDoctorAvailableToday(doctor);
          final appointmentCount = _getAppointmentCount(doctor['name']);
          final specialty = doctor['specialty'] ?? 'General Practitioner';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientsAppointments(
                        doctorName: doctor['name'],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Doctor Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color_codes.light_plus,
                        child: Icon(
                          Icons.medical_services,
                          size: 30,
                          color: Color_codes.deep_plus,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Doctor Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              specialty,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAvailable
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 14,
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAvailable
                                            ? 'Available'
                                            : 'Not Available',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isAvailable
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        doctor['visiting_time'] ??
                                            'N/A',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Appointment Count & Chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$appointmentCount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}