import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/model/medicine_model.dart';


class MedicinePage extends StatefulWidget {
  const MedicinePage({super.key});
  static String name = '/medicine-page';

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();
  String _filterCategory = 'All';
  Future<List<Medicine>>? _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() {
    setState(() {
      _medicinesFuture = FirebaseFirestore.instance
          .collection('medicines')
          .orderBy('name')
          .get()
          .then((snapshot) =>
          snapshot.docs.map((doc) => Medicine.fromFirestore(doc)).toList());
    });
    return _medicinesFuture!;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _searchTerm = _searchController.text.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchTerm = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Medicines"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Medicines Available"));
          }

          final medicines = snapshot.data!;
          final filteredData = medicines.where((medicine) {
            final searchMatch = _searchTerm.isEmpty ||
                medicine.name.toLowerCase().contains(_searchTerm.toLowerCase());
            final categoryMatch = _filterCategory == 'All' ||
                medicine.category == _filterCategory;

            return searchMatch && categoryMatch;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search medicines...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => setState(() => _searchTerm = value),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Expanded(
                child: filteredData.isEmpty
                    ? const Center(child: Text("No matching medicines found"))
                    : ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final medicine = filteredData[index];
                    final isLowStock = medicine.stock <= medicine.minStock;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          medicine.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("${medicine.category} • ${medicine.manufacturer}"),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text("Stock: ${medicine.stock}"),
                                if (isLowStock)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.warning,
                                        color: Colors.orange, size: 16),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (medicine.genericName != null)
                                  _buildDetailRow("Generic Name:", medicine.genericName!),
                                if (medicine.uses != null)
                                  _buildDetailRow("Uses:", medicine.uses!),
                                if (medicine.dosage != null)
                                  _buildDetailRow("Dosage:", medicine.dosage!),
                                if (medicine.sideEffects != null)
                                  _buildDetailRow("Side Effects:", medicine.sideEffects!),
                                if (medicine.expiry != null)
                                  _buildDetailRow("Expiry Date:",
                                      "${medicine.expiry!.toLocal()}".split(' ')[0]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}