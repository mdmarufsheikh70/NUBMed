import 'package:flutter/material.dart';
import 'package:nubmed/model/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isAvailable;
  final VoidCallback onBook;

  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.isAvailable,
    required this.onBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(doctor.name),
            // Text(doctor.specialization),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(doctor.imageUrl),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(doctor.specialization),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Degree + Designation
            Text("${doctor.degree}, ${doctor.designation}"),
            Text("Hospital: ${doctor.hospital}"),
            Text("Visiting Time: ${doctor.visitingTime}"),
            Text("Days: ${doctor.visitingDays.join(', ')}"),

            const SizedBox(height: 10),

            // Book Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: isAvailable ? onBook : null,
                child: Text(isAvailable ? "Book" : "Not Available"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
