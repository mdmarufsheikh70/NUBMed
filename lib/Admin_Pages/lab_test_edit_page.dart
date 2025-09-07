
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/model/lab_model.dart';

class LabTestEditPage extends StatefulWidget {
  final LabTest_Model? test;

  const LabTestEditPage({super.key, this.test});

  @override
  State<LabTestEditPage> createState() => _LabTestEditPageState();
}

class _LabTestEditPageState extends State<LabTestEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _sampleController;
  late TextEditingController _prepController;
  late TextEditingController _turnaroundController;
  late TextEditingController _rangeKeyController;
  late TextEditingController _rangeValueController;
  late Map<String, String> _normalRanges;

  final List<String> _categories = [
    'Hematology',
    'Biochemistry',
    'Microbiology',
    'Pathology',
    'Radiology',
    'Molecular Biology', // Add this
    'Immunology', // Add any other categories that might exist
    'Genetics', // Add any other categories that might exist
  ];

  @override
  void initState() {
    super.initState();
    final test = widget.test;
    _nameController = TextEditingController(text: test?.name ?? '');
    _categoryController = TextEditingController(
      text: test?.category ?? 'Hematology',
    );
    _priceController = TextEditingController(
      text: test?.price.toString() ?? '',
    );
    _sampleController = TextEditingController(
      text: test?.sampleType ?? 'Blood',
    );
    _prepController = TextEditingController(text: test?.preparation ?? '');
    _turnaroundController = TextEditingController(
      text: test?.turnaroundTime.toString() ?? '24',
    );
    _rangeKeyController = TextEditingController();
    _rangeValueController = TextEditingController();
    _normalRanges = {...test?.normalRanges ?? {}};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _sampleController.dispose();
    _prepController.dispose();
    _turnaroundController.dispose();
    _rangeKeyController.dispose();
    _rangeValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test == null ? 'Add New Test' : 'Edit Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Test Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _categories.contains(_categoryController.text)
                    ? _categoryController.text
                    : _categories.first,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (৳)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _sampleController,
                decoration: const InputDecoration(labelText: 'Sample Type'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _prepController,
                decoration: const InputDecoration(labelText: 'Preparation'),
              ),
              TextFormField(
                controller: _turnaroundController,
                decoration: const InputDecoration(
                  labelText: 'Turnaround Time (hours)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Normal Ranges:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._normalRanges.entries.map(
                (entry) => ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        setState(() => _normalRanges.remove(entry.key)),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rangeKeyController,
                      decoration: const InputDecoration(labelText: 'Parameter'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _rangeValueController,
                      decoration: const InputDecoration(
                        labelText: 'Normal Range',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_rangeKeyController.text.isNotEmpty &&
                          _rangeValueController.text.isNotEmpty) {
                        setState(() {
                          _normalRanges[_rangeKeyController.text] =
                              _rangeValueController.text;
                          _rangeKeyController.clear();
                          _rangeValueController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTest,
                child: Text(widget.test == null ? 'Add Test' : 'Update Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTest() {
    if (_formKey.currentState!.validate()) {
      final data = LabTest_Model(
        id: '',
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        sampleType: _sampleController.text.trim(),
        turnaroundTime:int.parse(_turnaroundController.text.trim()),
        preparation: _prepController.text.trim(),
        normalRanges: _normalRanges,
        isActive: true,
      );
      final future =widget.test == null
          ? FirebaseFirestore.instance
                .collection('labtests')
                .add(data.toFirestore())
          : FirebaseFirestore.instance
                .collection('labtests')
                .doc(widget.test!.id)
                .update(data.toFirestore());
      future.then((_){
        Navigator.pop(context,true);
        showSnackBar(context, "Updated successfully", false);
      }).catchError((error){
        showSnackBar(context, 'Error: $error', true);
      });
    }
  }
}
