import 'package:flutter/material.dart';
import 'package:nubmed/pages/Appointment/AppoinmentPage.dart';
import 'package:nubmed/pages/Lab%20Test/your_lab_test_page.dart';
import 'package:nubmed/utils/currentUserInfo.dart';

class AppointmentsHomePage extends StatelessWidget {
  const AppointmentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments Home"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Doctor Appointments Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Appointmentpage(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services, size: 40, color: Colors.blue),
                      SizedBox(width: 16),
                      Text(
                        "Your Doctor Appointments",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Lab Test Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => YourLabTestPage(currentUserId: CurrentUserInfo.uid),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(Icons.science, size: 40, color: Colors.green),
                      SizedBox(width: 16),
                      Text(
                        "Your Lab Tests",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}