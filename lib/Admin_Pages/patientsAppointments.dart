import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/model/appointment_model.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/image_viewer.dart';
import 'package:nubmed/utils/pickImage_imgbb.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PatientsAppointments extends StatefulWidget {
  const PatientsAppointments({super.key, required this.doctorName});
  final String doctorName;
  static String name = '/patients-appointments';

  @override
  State<PatientsAppointments> createState() => _PatientsAppointmentsState();
}

class _PatientsAppointmentsState extends State<PatientsAppointments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyPending = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Query dateAppointment(DateTime? selectedDate) {
    Query query = _firestore.collection('appointments')
        .where('doctorName', isEqualTo: widget.doctorName)
        .orderBy('serialNumber');

    if (selectedDate != null) {
      final startDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

      return query
          .where('appointmentDate', isGreaterThanOrEqualTo: startDate)
          .where('appointmentDate', isLessThanOrEqualTo: endDate);
    } else {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return query
          .where('appointmentDate', isGreaterThanOrEqualTo: todayStart)
          .where('appointmentDate', isLessThanOrEqualTo: todayEnd);
    }
  }

  Stream<List<Appointment>> get _filteredAppointments {
    return dateAppointment(_selectedDate).snapshots().map((snapshot) {
      List<Appointment> appointments = snapshot.docs
          .map((doc) => Appointment.fromFirestore(doc))
          .toList();

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        appointments = appointments.where((appointment) =>
        appointment.userName.toLowerCase().contains(_searchQuery) ||
            appointment.userStudentId.toLowerCase().contains(_searchQuery) ||
            appointment.userPhone.contains(_searchQuery)).toList();
      }

      // Apply status filter
      if (_showOnlyPending) {
        appointments = appointments.where((appointment) => !appointment.visited).toList();
      }

      return appointments;
    });
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
              primary: Color_codes.deep_plus,
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
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments - ${widget.doctorName}'),
        centerTitle: true,
        backgroundColor: Color_codes.deep_plus,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
            tooltip: 'Filter by date',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    // Date Filter Chip
                    if (_selectedDate != null)
                      FilterChip(
                        label: Text(
                          DateFormat('MMM d').format(_selectedDate!),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color_codes.deep_plus,
                        onSelected: (_) => _clearDateFilter(),
                        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    const Spacer(),
                    // Pending Only Filter
                    FilterChip(
                      label: Text(
                        _showOnlyPending ? 'Pending Only' : 'All Status',
                        style: TextStyle(
                          color: _showOnlyPending ? Colors.white : Colors.black,
                        ),
                      ),
                      backgroundColor: _showOnlyPending
                          ? Colors.orange : Colors.grey[300],
                      onSelected: (selected) {
                        setState(() {
                          _showOnlyPending = selected;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date Header
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.blue[50],
              child: Center(
                child: Text(
                  'Appointments for: ${DateFormat('EEEE, MMMM d, y').format(_selectedDate!)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color_codes.deep_plus,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Appointments List
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _filteredAppointments,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color_codes.deep_plus),
                    ),
                  );
                }

                final appointments = snapshot.data ?? [];

                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            Icons.event_busy,
                            size: 60,
                            color: Colors.grey.shade400
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _showOnlyPending || _selectedDate != null
                              ? 'No matching appointments found'
                              : 'No appointments scheduled',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isNotEmpty || _showOnlyPending || _selectedDate != null)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _showOnlyPending = false;
                                _selectedDate = null;
                              });
                            },
                            child: const Text('Clear all filters'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final isVisited = appointment.visited;

                    return _buildAppointmentCard(appointment, isVisited);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _printPage();
        },
        icon: const Icon(Icons.print, size: 20),
        label: const Text("Print List"),
        backgroundColor: Color_codes.deep_plus,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isVisited) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isVisited ? Colors.green.shade100 : Colors.orange.shade100,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ID: ${appointment.userStudentId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${appointment.userPhone}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isVisited
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isVisited
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                      ),
                    ),
                    child: Text(
                      isVisited ? 'VISITED' : 'PENDING',
                      style: TextStyle(
                        color: isVisited
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 16),

              // Appointment Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    icon: Icons.calendar_today,
                    text: appointment.formattedAppointmentDate,
                    color: Color_codes.deep_plus,
                  ),
                  _buildDetailItem(
                    icon: Icons.schedule,
                    text: appointment.visitingTime,
                    color: Colors.blue.shade700,
                  ),
                  _buildDetailItem(
                    icon: Icons.format_list_numbered_rtl,
                    text: 'Serial #${appointment.serialNumber}',
                    color: Colors.orange.shade700,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Action Buttons
              if (isVisited)
                _buildPrescriptionSection(appointment)
              else
                _buildActionButtons(appointment),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPrescriptionSection(Appointment appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (appointment.prescription.isNotEmpty ?? false)
          Column(
            children: [
              const Text(
                'Prescription Uploaded',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload, size: 18),
                    label: const Text('Upload Again'),
                    onPressed: () async{
                      await _uploadPrescription(appointment);

                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Prescription'),
                    onPressed: () {
                      showImage(appointment.prescription, context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          FilledButton.icon(
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Prescription'),
            onPressed: () async {
              await _uploadPrescription(appointment);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Color_codes.deep_plus,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(Appointment appointment) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Mark Visited'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color_codes.deep_plus,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _updateAppointmentStatus(appointment, true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Mark Absent'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _updateAppointmentStatus(appointment, false),
          ),
        ),
      ],
    );
  }

  Future<void> _printPage() async {
    final pdf = pw.Document();

    final data = await dateAppointment(_selectedDate).get();
    final formattedDate = DateFormat("d MMM yyyy").format(_selectedDate ?? DateTime.now());

    final List<Appointment> dataList =
    data.docs.map((e) => Appointment.fromFirestore(e)).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Appointments For ${widget.doctorName}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  "Visiting Time: ${dataList.isNotEmpty ? dataList[0].visitingTime : 'N/A'}",
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  "Date: $formattedDate",
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Appointment Table
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FlexColumnWidth(3),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              // Table Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("No", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Name", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Student ID", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Phone", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Status", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),

              ...dataList.map((appt) {
                return pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(appt.serialNumber.toString())),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(appt.userName)),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(appt.userStudentId)),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(appt.userPhone)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        appt.visited ? "Visited" : "Pending",
                        style: pw.TextStyle(
                          color: appt.visited ? PdfColors.green : PdfColors.orange,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          )
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _updateAppointmentStatus(Appointment appointment, bool visited) async {
    try {
      await _firestore.collection('appointments').doc(appointment.id).update({
        'visited': visited,
        'processedBy': _auth.currentUser?.uid,
        'processedAt': FieldValue.serverTimestamp(),
      });

      await _sendNotificationToPatient(appointment, visited);

      if (!mounted) return;
      showSnackBar(
        context,
        'Appointment marked as ${visited ? "Visited" : "Absent"}',
        visited,
      );
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, 'Error: ${e.toString()}', false);
    }
  }

  Future<void> _sendNotificationToPatient(Appointment appointment, bool visited) async {
    await _firestore.collection('notifications').add({
      'userId': appointment.userId,
      'title': 'Appointment Status',
      'message': 'Your appointment has been marked as ${visited ? "Visited" : "Absent"}',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<void> _uploadPrescription(Appointment appointment) async {
    XFile? pickedImage = await ImgBBImagePicker.pickImage();
    if (pickedImage != null) {
      ImgBBResponse? response = await ImgBBImagePicker.uploadImage(
        imageFile: pickedImage,
        context: context,
      );
      if (response != null) {
        await _firestore.collection('appointments').doc(appointment.id).update({
          'prescription': response.imageUrl,
        });
        showSnackBar(context, "Prescription Uploaded", false);
      }
    }
  }
}