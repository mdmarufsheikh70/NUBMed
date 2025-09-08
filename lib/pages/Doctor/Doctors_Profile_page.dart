import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/Widgets/normalTitle.dart';
import 'package:nubmed/model/doctor_model.dart';
import 'package:nubmed/pages/Admin_Pages/addOrUpdate_doctor.dart';

class DoctorsProfilePage extends StatefulWidget {
  DoctorsProfilePage({
    super.key,
    required this.doctor
  });

  Doctor doctor;
  static String name = '/doctor-profile';

  @override
  State<DoctorsProfilePage> createState() => _DoctorsProfilePageState();
}

class _DoctorsProfilePageState extends State<DoctorsProfilePage> {

  @override
  Widget build(BuildContext context) {
    final doctorInfo = widget.doctor;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Profile"),
        actions: [
          if (Administrator.isAdminUser)
            IconButton(
              onPressed: () async {
                final updatedDoctor = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrUpdateNewDoctor(doctor: doctorInfo),
                  ),
                );

                if (updatedDoctor != null) {
                  setState(() {
                    widget.doctor = updatedDoctor; // Update with the returned doctor
                  });
                  Navigator.pop(context,updatedDoctor);
                }
              },
              icon: const Icon(Icons.edit_note, color: Colors.white),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "doctor_${doctorInfo.id}",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: doctorInfo.imageUrl,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: 250,
                      placeholder: (context,x){
                        return CircularProgressIndicator();
                      },
                      errorWidget: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/blank person.jpg",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250,
                        );
                      },
                    ),
                  ),
            ),
            const SizedBox(height: 24),

            // Name
            Normal_Title(title: "Name"),
            Text(doctorInfo.name, style: _valueStyle()),

            const SizedBox(height: 16),

            // Degree
            Normal_Title(title: "Degree"),
            Text(doctorInfo.degree, style: _valueStyle()),

            const SizedBox(height: 16),

            // Designation
            Normal_Title(title: "Designation"),
            Text(doctorInfo.designation, style: _valueStyle()),

            const SizedBox(height: 16),

            // Hospital
            Normal_Title(title: "Hospital"),
            Text(doctorInfo.hospital, style: _valueStyle()),

            const SizedBox(height: 16),

            // Specialization
            Normal_Title(title: "Specialization"),
            Text(
              doctorInfo.specialization,
              style: _valueStyle(),
            ),

            const SizedBox(height: 16),

            // Visiting Days
            Normal_Title(title: "Visiting Days"),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (doctorInfo.visitingDays as List<dynamic>? ?? [])
                  .map(
                    (day) => Chip(
                      label: Text(day),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(color: Colors.black87),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Visiting Time
            Normal_Title(title: "Visiting Time"),
            Text(doctorInfo.visitingTime, style: _valueStyle()),
          ],
        ),
      ),
    );
  }

  TextStyle _valueStyle() {
    return const TextStyle(fontSize: 16, color: Colors.black87);
  }

  // String _getSpecializationDisplayName(String? specString) {
  //   if (specString == null || specString.isEmpty) return 'Not specified';
  //
  //   try {
  //     // Remove enum class prefix if present
  //     final cleanSpecString = specString.replaceFirst('DoctorSpecialization.', '');
  //     final spec = DoctorSpecialization.values.firstWhere(
  //           (e) => e.toString().endsWith(cleanSpecString),
  //       orElse: () => DoctorSpecialization.all,
  //     );
  //     return spec.displayName;
  //   } catch (e) {
  //     debugPrint('Error parsing specialization: $e');
  //     return specString; // Fallback to raw string if parsing fails
  //   }
  // }
}
