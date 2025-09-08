import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/Widgets/LabTestCard.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/model/lab_model.dart';
import 'package:nubmed/model/users_labTest_model.dart';
import 'package:nubmed/pages/Admin_Pages/lab_test_edit_page.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/currentUserInfo.dart';

class LabTestPage extends StatefulWidget {
  const LabTestPage({super.key});

  @override
  State<LabTestPage> createState() => _LabTestPageState();
}

class _LabTestPageState extends State<LabTestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Future<List<LabTest_Model>>? _testsFuture;

  final List<String> _categories = [
    'Hematology',
    'Biochemistry',
    'Microbiology',
    'Pathology',
    'Radiology',
    'Molecular Biology', // Add this
    'Immunology',       // Add any other categories that might exist
    'Genetics',         // Add any other categories that might exist
  ];

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

   Future<void> _loadTests() async {
    setState(() {
      _testsFuture = _fetchTests();
    });
  }

  Future<List<LabTest_Model>> _fetchTests() async {
    try {
      final snapshot = await _firestore.collection('labtests').get();
      return snapshot.docs.map((doc) => LabTest_Model.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load tests: $e');
    }
  }

  List<LabTest_Model> _filterTests(List<LabTest_Model> tests) {
    return tests.where((test) {
      final matchesSearch = test.name.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' ||
          test.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Lab Tests'),
        centerTitle: true,
        actions: [
          if(Administrator.isAdminUser || Administrator.isModeratorUser)
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LabTestEditPage()),
                );
                if (result == true) {
                  _loadTests();
                }
              },
              label: Text("Add", style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.add, color: Colors.white),
            )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildTestList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tests...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: _selectedCategory == _categories[index],
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? _categories[index] : 'All';
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestList() {
    return FutureBuilder<List<LabTest_Model>>(
      future: _testsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tests available'));
        }

        final filteredTests = _filterTests(snapshot.data!);

        if (filteredTests.isEmpty) {
          return const Center(child: Text('No matching tests found'));
        }

        return RefreshIndicator(
          onRefresh: _loadTests,
          child: ListView.builder(
            itemCount: filteredTests.length,
            itemBuilder: (context, index) {
              return LabTestCard(
                test: filteredTests[index],
                onTap: () => _showTestDetails(context, filteredTests[index]),
                onTestUpdated: _loadTests,
              );
            },
          ),
        );
      },
    );
  }

  void _showTestDetails(BuildContext context, LabTest_Model test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                test.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(test.category),
                backgroundColor: Colors.blue[50],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Sample Type', test.sampleType),
              _buildDetailRow('Preparation', test.preparation),
              _buildDetailRow('Turnaround Time', '${test.turnaroundTime} hours'),
              _buildDetailRow('Price', '৳${test.price.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text(
                'Normal Ranges:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...test.normalRanges.entries.map(
                    (entry) => _buildDetailRow(entry.key, entry.value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _bookTest(context, test),
                  child: const Text('Book This Test'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _bookTest(BuildContext context, LabTest_Model test) async {
    bool isProcessing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Confirm Booking"),
              content: isProcessing
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text('Booking ${test.name}...'),
                ],
              )
                  : Text(
                "Are you sure you want to book the test:\n\n"
                    "${test.name} (৳${test.price.toStringAsFixed(2)})",
              ),
              actions: [
                if (!isProcessing) TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                if (isProcessing)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color_codes.middle_plus,
                    ),
                    onPressed: () async {
                      setState(() => isProcessing = true);

                      try {
                        // Your booking logic here
                        final today = DateTime.now();
                        final startOfDay = DateTime(today.year, today.month, today.day);
                        final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

                        final serialSnapshot = await FirebaseFirestore.instance
                            .collection('usersLabTest')
                            .where('testName', isEqualTo: test.name)
                            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                            .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
                            .get();

                        final booking = UsersLabtestModel(
                          labID: test.id,
                          testName: test.name,
                          testPrice: test.price,
                          userId: CurrentUserInfo.uid,
                          serial: serialSnapshot.docs.length + 1,
                          isDone: false,
                          timestamp: DateTime.now(),
                          report: '',
                        );

                        await FirebaseFirestore.instance
                            .collection("usersLabTest")
                            .add(booking.toFirestore());

                        if (context.mounted) {
                          Navigator.pop(context, true); // Close with success
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                  ),
              ],
            );
          },
        );
      },
    ).then((success) {
      if (success == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${test.name} booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }


}