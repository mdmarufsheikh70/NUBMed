import 'package:flutter/material.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/model/lab_model.dart';
import 'package:nubmed/pages/Admin_Pages/lab_test_edit_page.dart';


class LabTestCard extends StatelessWidget {
  final LabTest_Model test;
  final VoidCallback onTap;
  final VoidCallback? onTestUpdated;

  const LabTestCard({super.key, required this.test, required this.onTap,this.onTestUpdated,});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      test.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Chip(
                      label: Text(test.category),
                      backgroundColor: Colors.blue[50],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bloodtype, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(test.sampleType),
                  const Spacer(),
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text('${test.turnaroundTime} hrs'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '৳${test.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  TextButton(
                    onPressed: onTap,
                    child: const Text('View Details'),
                  ),
                  if(Administrator.isAdminUser || Administrator.isModeratorUser)
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LabTestEditPage(test: test)),
                        );
                        if (result == true && onTestUpdated != null) {
                          onTestUpdated!();
                        }
                      },
                      child: const Text('Edit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}