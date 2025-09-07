import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHealthTipsPage extends StatefulWidget {
  const AdminHealthTipsPage({super.key});
  static String name = '/admin-health-tips';

  @override
  State<AdminHealthTipsPage> createState() => _AdminHealthTipsPageState();
}

class _AdminHealthTipsPageState extends State<AdminHealthTipsPage> {
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _fetchTips() async {
    final snapshot = await FirebaseFirestore.instance.collection('healthtips').get();
    return snapshot.docs;
  }

  void _showTipDialog({DocumentSnapshot? doc}) {
    final titleController = TextEditingController(text: doc?['title']);
    final whyController = TextEditingController(text: doc?['why_occurs']);
    final symptomsController = TextEditingController(text: doc?['symptoms']?.join('\n'));
    final remediesController = TextEditingController(text: doc?['home_remedies']?.join('\n'));
    final seeDoctorController = TextEditingController(text: doc?['when_to_see_doctor']);
    final specialistsController = TextEditingController(text: doc?['specialists']?.join('\n'));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? 'Add Tip' : 'Edit Tip'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field("Title", titleController),
              _field("Why it occurs", whyController),
              _field("Symptoms (one per line)", symptomsController, maxLines: 3),
              _field("Home Remedies (one per line)", remediesController, maxLines: 3),
              _field("When to see a doctor", seeDoctorController),
              _field("Specialists (one per line)", specialistsController, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleController.text.trim(),
                'why_occurs': whyController.text.trim(),
                'symptoms': symptomsController.text.trim().split('\n'),
                'home_remedies': remediesController.text.trim().split('\n'),
                'when_to_see_doctor': seeDoctorController.text.trim(),
                'specialists': specialistsController.text.trim().split('\n'),
              };

              if (doc == null) {
                await FirebaseFirestore.instance.collection('healthtips').add(data);
              } else {
                await FirebaseFirestore.instance.collection('healthtips').doc(doc.id).update(data);
              }

              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _deleteTip(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Tip"),
        content: const Text("Are you sure you want to delete this health tip?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('healthtips').doc(id).delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Health Tips"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTipDialog(),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchTips(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tips = snapshot.data!;
          if (tips.isEmpty) return const Center(child: Text("No tips available"));

          return ListView.builder(
            itemCount: tips.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final doc = tips[index];
              return Card(
                child: ListTile(
                  title: Text(doc['title']),
                  subtitle: Text(doc['why_occurs'], maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showTipDialog(doc: doc)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTip(doc.id)),
                    ],
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
