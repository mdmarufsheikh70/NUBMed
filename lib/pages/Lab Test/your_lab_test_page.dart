import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/model/users_labTest_model.dart';
import 'package:intl/intl.dart';

class YourLabTestPage extends StatefulWidget {
  final String currentUserId;
  const YourLabTestPage({super.key, required this.currentUserId});

  @override
  State<YourLabTestPage> createState() => _YourLabTestPageState();
}

class _YourLabTestPageState extends State<YourLabTestPage> {
  Future<List<UsersLabtestModel>> _fetchLabTests() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("usersLabTest")
        .where("userId", isEqualTo: widget.currentUserId)
        .orderBy("timestamp", descending: true)
        .get();

    return snapshot.docs.map((doc) => UsersLabtestModel.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Lab Tests", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchLabTests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No Lab Tests Found",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You haven't booked any lab tests yet",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final tests = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              final date = test.timestamp;
              final formattedDate = DateFormat('MMM dd, yyyy').format(date);
              final formattedTime = DateFormat('hh:mm a').format(date);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Add detailed view functionality here
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with test name and status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  test.testName ?? "Unknown Test",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: test.isDone
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  test.isDone ? "COMPLETED" : "PENDING",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: test.isDone ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 18, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                "Price: ${test.testPrice}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.confirmation_number, size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                "Serial: ${test.serial}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                "Booked: $formattedDate",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text(
                                "Time: $formattedTime",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Action buttons
                          if (!test.isDone) Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async{
                                    final list = await FirebaseFirestore.instance.collection("usersLabTest").get();
                                    final doc = list.docs;
                                    for(QueryDocumentSnapshot d in doc){
                                      final x = UsersLabtestModel.fromFirestore(d);
                                      if(x.serial>test.serial){
                                        final newSerial = x.serial -1;
                                        FirebaseFirestore.instance.collection("usersLabTest").doc(x.labID).update({
                                          'serial':newSerial
                                        });
                                      }
                                    }
                                    await FirebaseFirestore.instance.collection("usersLabTest").doc(test.labID).delete();
                                    setState(() {

                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Cancel Test"),
                                ),
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
          );
        },
      ),
    );
  }
}