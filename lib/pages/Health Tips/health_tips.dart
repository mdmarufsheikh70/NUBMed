import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/utils/Color_codes.dart';

class HealthTips extends StatelessWidget {
  const HealthTips({super.key});

  static String name = '/health-tips';

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getHealthTips() async {
    final snapshot = await FirebaseFirestore.instance.collection('healthtips').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Health Tips'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _getHealthTips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No health tips available."));
          }

          final tips = snapshot.data!;

          return ListView.builder(
            itemCount: tips.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final data = tips[index].data();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: sectionTitle(data['title'])),
                  subheading("Why it occurs"),
                  bodyText(data['why_occurs']),
                  subheading("Symptoms"),
                  bulletPoints(List<String>.from(data['symptoms'])),
                  subheading("Home Remedies"),
                  bulletPoints(List<String>.from(data['home_remedies'])),
                  subheading("When to see a doctor"),
                  bodyText(data['when_to_see_doctor']),
                  subheading("Specialists"),
                  bulletPoints(List<String>.from(data['specialists'])),
                  const SizedBox(height: 25),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      title,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color_codes.deep_plus),
    ),
  );

  Widget subheading(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
  );

  Widget bodyText(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, height: 1.5),
  );

  Widget bulletPoints(List<String> points) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: points
        .map((point) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text("• $point", style: const TextStyle(fontSize: 15)),
    ))
        .toList(),
  );
}
