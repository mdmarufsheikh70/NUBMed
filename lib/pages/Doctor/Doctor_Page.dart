

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/model/appointment_model.dart';
import 'package:nubmed/model/user_model.dart';
import 'package:nubmed/pages/Doctor/Doctors_Profile_page.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/specialization_list.dart';

import '../../model/doctor_model.dart';
import '../Admin_Pages/addOrUpdate_doctor.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});
  static String name = '/doctor-page';

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  String? selectedSpecialization;
  Future<List<Doctor>>? _doctorsFuture;


  Future<DateTime?> showDoctorAppointmentPicker(
      BuildContext context,
      List<String> availableDays,
      String visitingTime,
      ) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime endOfNextWeek = today.add(const Duration(days: 13));

    DateTime? firstAvailableDate;
    for (int i = 0; i <= 13; i++) {
      final candidate = today.add(Duration(days: i));
      final dayName = DateFormat('EEEE').format(candidate);
      if (availableDays.contains(dayName)) {
        if (i == 0) {
          try {
            final parsedTime = DateFormat.jm().parse(visitingTime);
            final visitingToday = DateTime(
              candidate.year,
              candidate.month,
              candidate.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            if (now.isBefore(visitingToday)) {
              firstAvailableDate = candidate;
              break;
            }
          } catch (_) {}
        } else {
          firstAvailableDate = candidate;
          break;
        }
      }
    }

    if (firstAvailableDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No available appointment days left")),
      );
      return null;
    }

    return await showDatePicker(
      context: context,
      initialDate: firstAvailableDate,
      firstDate: today,
      lastDate: endOfNextWeek,
      selectableDayPredicate: (date) {
        final dayName = DateFormat('EEEE').format(date);
        if (!availableDays.contains(dayName)) return false;
        if (DateUtils.isSameDay(date, today)) {
          try {
            final parsedTime = DateFormat.jm().parse(visitingTime);
            final visitingToday = DateTime(
              date.year,
              date.month,
              date.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            return now.isBefore(visitingToday);
          } catch (_) {
            return false;
          }
        }
        return true;
      },
    );
  }

  @override
  void initState() {
    _loadDoctors();
    super.initState();
  }

  void _loadDoctors() {
    _doctorsFuture = FirebaseFirestore.instance
        .collection('doctors')
        .get()
        .then(
          (snapshot) =>
          snapshot.docs.map((e) => Doctor.fromFirestore(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Doctors"),
        centerTitle: true,
        actions: [
          if (Administrator.isAdminUser)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AddOrUpdateNewDoctor.name).then((_)=>_loadDoctors());
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
        ],
      ),
      body: FutureBuilder<List<Doctor>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctors = snapshot.data??[];

          if (doctors.isEmpty) {
            return const Center(child: Text("No Doctors Available"));
          }

          final filteredDocs =
          (selectedSpecialization == null ||
              selectedSpecialization == 'All')
              ? doctors
              : doctors.where((d) {
            return d.specialization == selectedSpecialization.toString();
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5.0),
                DropdownButtonFormField<String>(
                  value: selectedSpecialization,
                  hint: const Text(
                    "Select Specialization",
                    style: TextStyle(fontSize: 14.0),
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color_codes.meddle,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color_codes.meddle,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color_codes.meddle,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 12.0,
                    ),
                  ),
                  items: Specialization.doctor_specializaton
                      .map(
                        (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedSpecialization = value),
                ),
                const SizedBox(height: 12.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDocs[index];
                      final isAvailable = isDoctorAvailableToday(doctor.visitingDays);

                      return GestureDetector(
                        onTap: () async {
                          final updatedDoctor = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorsProfilePage(doctor: doctor),
                            ),
                          );
                          if (updatedDoctor != null) {
                            setState(() {
                              // Update both the main list and filtered list
                              final index = doctors.indexWhere((d) => d.id == updatedDoctor.id);
                              if (index != -1) {
                                doctors[index] = updatedDoctor;

                                // Also update filteredDocs if this doctor is in it
                                final filteredIndex = filteredDocs.indexWhere((d) => d.id == updatedDoctor.id);
                                if (filteredIndex != -1) {
                                  filteredDocs[filteredIndex] = updatedDoctor;
                                }
                              }
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: "doctor_${doctor.id}",
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(14)),
                                  child: CachedNetworkImage(
                                    imageUrl: doctor.imageUrl,
                                    width: 120,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorWidget: (context, url, error) {
                                      return Image.asset(
                                        "assets/blank person.jpg",
                                        width: 120,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Doctor Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        doctor.degree,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        doctor.specialization,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        'Visiting Time: ${doctor.visitingTime}',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAvailable
                                              ? Colors.green[50]
                                              : Colors.red[50],
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                        child: Text(
                                          isAvailable
                                              ? "Available Today"
                                              : "Not Available Today",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600,
                                            color: isAvailable
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          _bookAppointment(doctor);
                                        },
                                        child: const Text(
                                          "Make Appointment",
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool isDoctorAvailableToday(List<dynamic> availableDays) {
    try {
      final now = DateTime.now();
      final todayName = DateFormat('EEEE').format(now);

      // Convert all day names to lowercase for case-insensitive comparison
      final availableDayNames = availableDays
          .map((day) => day.toString().toLowerCase())
          .toList();

      // Check if today is in availableDays
      final isAvailable = availableDayNames.contains(todayName.toLowerCase());

      if (!isAvailable) {
        debugPrint(
          'Doctor not available today (Today: $todayName, Available: $availableDays)',
        );
      }

      return isAvailable;
    } catch (e) {
      debugPrint("Error checking availability: $e");
      return false;
    }
  }

  Future<void> _bookAppointment(Doctor doctor) async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        showSnackBar(context, "You must be logged in", true);
        return;
      }

      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final user = medUser.fromFirestore(userDoc);

      // Date selection
      final selectedDate = await showDoctorAppointmentPicker(
        context,
        doctor.visitingDays,
        doctor.visitingTime,
      );
      if (selectedDate == null) return;

      // Check for existing appointment
      final existing = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.id)
          .where('userId', isEqualTo: user.id)
          .where(
        'appointmentDate',
        isGreaterThanOrEqualTo: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ),
      )
          .where(
        'appointmentDate',
        isLessThan: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + 1,
        ),
      )
          .get();

      if (existing.docs.isNotEmpty) {
        showSnackBar(
          context,
          "You already have an appointment with this doctor today",
          true,
        );
        return;
      }

      // Combine date and time
      final time = DateFormat.jm().parse(doctor.visitingTime);
      final appointmentDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time.hour,
        time.minute,
      );

      // Get serial number
      final appointments = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.id)
          .where(
        'appointmentDate',
        isGreaterThanOrEqualTo: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ),
      )
          .where(
        'appointmentDate',
        isLessThan: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + 1,
        ),
      )
          .get();

      // Create appointment
      final appointment = Appointment(
        id: '',
        appointmentDate: appointmentDateTime,
        doctorId: doctor.id!,
        doctorName: doctor.name,
        doctorSpecialization: doctor.specialization,
        serialNumber: appointments.docs.length + 1,
        timestamp: DateTime.now(),
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        userStudentId: user.studentId,
        visited: false,
        visitingTime: doctor.visitingTime,
        prescription: '',
      );

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointment.toFirestore());

      showSnackBar(
        context,
        'Appointment booked for ${DateFormat('MMMM d').format(selectedDate)} at ${doctor.visitingTime}',
        false,
      );
    } catch (e) {
      showSnackBar(context, 'Failed to book appointment: ${e.toString()}', true);
    }
  }
}