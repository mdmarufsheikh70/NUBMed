import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/pages/Report and Prescription/PrescriptionsTab.dart';
import 'package:nubmed/pages/Report and Prescription/lab_report_tab.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Medical Report and Prescription"),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(text: "Your Prescriptions"),
              Tab(text: "Your Lab Test Reports"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrescriptionsTab(),
            LabReportsTab(),
          ],
        ),
      ),
    );
  }
}
