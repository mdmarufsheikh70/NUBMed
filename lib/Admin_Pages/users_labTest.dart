import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/model/user_model.dart';
import 'package:nubmed/model/users_labTest_model.dart';
import 'package:nubmed/utils/pickImage_imgbb.dart';
import 'package:intl/intl.dart';

class UsersLabtest extends StatefulWidget {
  const UsersLabtest({super.key});

  @override
  State<UsersLabtest> createState() => _UsersLabtestState();
}

class _UsersLabtestState extends State<UsersLabtest> {
  final Map<String, medUser> _userCache = {};
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Set default to today's date
    _selectedDate = DateTime.now();
    _prefetchUsers();
  }

  Future<void> _prefetchUsers() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      for (final doc in usersSnapshot.docs) {
        final user = medUser.fromFirestore(doc);
        _userCache[doc.id] = user;
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Query _getFilteredQuery() {
    Query query = FirebaseFirestore.instance
        .collection('usersLabTest')
        .orderBy("timestamp", descending: true);

    // Always filter by date - default is today
    final filterDate = _selectedDate ?? DateTime.now();
    final startDate = DateTime(filterDate.year, filterDate.month, filterDate.day);
    final endDate = DateTime(filterDate.year, filterDate.month, filterDate.day, 23, 59, 59);

    return query
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today instead of null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users Lab Tests"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
            tooltip: 'Filter by date',
          ),
          // Show clear button only if not viewing today
          if (_selectedDate != null && !_isToday(_selectedDate!))
            IconButton(
              icon: const Icon(Icons.today, color: Colors.white),
              onPressed: _clearDateFilter,
              tooltip: 'Show today\'s tests',
            ),
        ],
      ),
      body: Column(
        children: [
          // Date Filter Header - Always show since we always have a date filter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isToday(_selectedDate!)
                      ? "Today's Lab Tests"
                      : 'Showing tests for: ${DateFormat('MMMM d, y').format(_selectedDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!_isToday(_selectedDate!))
                  IconButton(
                    icon: const Icon(Icons.today, size: 18),
                    onPressed: _clearDateFilter,
                    tooltip: 'Show today\'s tests',
                  ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
              stream: _getFilteredQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          "Something went wrong",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            _prefetchUsers();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.science, size: 50, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _isToday(_selectedDate!)
                              ? "No lab tests for today"
                              : "No lab tests on selected date",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (!_isToday(_selectedDate!))
                          TextButton(
                            onPressed: _clearDateFilter,
                            child: const Text('Show today\'s tests'),
                          ),
                      ],
                    ),
                  );
                }

                final labDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: labDocs.length,
                  itemBuilder: (context, index) {
                    final doc = labDocs[index];
                    final labData = UsersLabtestModel.fromFirestore(doc);
                    final user = _userCache[labData.userId];

                    if (user == null) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.person_off, color: Colors.grey),
                          title: Text(labData.testName),
                          subtitle: const Text("User information not available"),
                        ),
                      );
                    }

                    return _buildLabTestCard(labData, user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildLabTestCard(UsersLabtestModel labData, medUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and status
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundImage: (user.photoUrl.isNotEmpty)
                      ? NetworkImage(user.photoUrl)
                      : null,
                  onBackgroundImageError: (user.photoUrl.isNotEmpty)
                      ? (exception, stackTrace) {
                    debugPrint("Image load failed: $exception");
                  }
                      : null,
                  child: (user.photoUrl.isEmpty)
                      ? const Icon(Icons.person, size: 24)
                      : null,
                  backgroundColor: Colors.grey[200],
                ),

                const SizedBox(width: 12),

                // User and Test Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labData.testName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: labData.isDone ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: labData.isDone ? Colors.green.shade200 : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        labData.isDone ? Icons.check_circle : Icons.pending,
                        size: 16,
                        color: labData.isDone ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        labData.isDone ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: labData.isDone ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Test Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.attach_money, 'Price: ${labData.testPrice} BDT'),
                _buildDetailRow(Icons.phone, 'Phone: ${user.phone}'),
                _buildDetailRow(Icons.calendar_today,
                    'Booked: ${DateFormat('MMM dd, yyyy - hh:mm a').format(labData.timestamp)}'),

                // Show report if available
                if (labData.report != null && labData.report!.isNotEmpty)
                  _buildDetailRow(Icons.description, 'Report: Available'),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!labData.isDone)
                  ElevatedButton.icon(
                    onPressed: () => _markTestAsDone(labData),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),

                const SizedBox(width: 8),

                if (labData.isDone)
                  ElevatedButton.icon(
                    onPressed: () => _uploadLabReport(labData),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: Text(labData.report != null ? 'Update Report' : 'Upload Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),

                if (labData.report != null && labData.report!.isNotEmpty)
                  const SizedBox(width: 8),

                if (labData.report != null && labData.report!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _viewLabReport(labData.report!),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markTestAsDone(UsersLabtestModel labData) async {
    try {
      await FirebaseFirestore.instance
          .collection('usersLabTest')
          .doc(labData.labID)
          .update({'isDone': true});

      await _sendTestCompletionNotification(labData.userId, labData.testName);

      if (mounted) {
        showSnackBar(context, 'Test marked as completed successfully', true);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error: ${e.toString()}', false);
      }
    }
  }

  Future<void> _uploadLabReport(UsersLabtestModel labData) async {
    try {
      XFile? pickedImage = await ImgBBImagePicker.pickImage();
      if (pickedImage != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading lab report...'),
              ],
            ),
          ),
        );

        ImgBBResponse? response = await ImgBBImagePicker.uploadImage(
          imageFile: pickedImage,
          context: context,
        );

        Navigator.of(context).pop();

        if (response != null) {
          await FirebaseFirestore.instance
              .collection('usersLabTest')
              .doc(labData.labID)
              .update({
            'report': response.imageUrl,
            'reportUploadedAt': FieldValue.serverTimestamp(),
          });

          await _sendReportUploadNotification(labData.userId, labData.testName);

          if (mounted) {
            showSnackBar(context, "Lab Report Uploaded Successfully", true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error uploading report: ${e.toString()}', false);
      }
    }
  }

  void _viewLabReport(String reportUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Lab Test Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          reportUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                                  SizedBox(height: 8),
                                  Text('Failed to load report'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendTestCompletionNotification(String userId, String testName) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Lab Test Completed',
        'message': 'Your $testName test has been completed.',
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'test_completion',
        'read': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _sendReportUploadNotification(String userId, String testName) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Lab Report Ready',
        'message': 'Your $testName report has been uploaded and is ready for review.',
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'report_upload',
        'read': false,
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}