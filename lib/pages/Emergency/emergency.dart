import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/emergency.dart';

class EmergencyScreen extends StatelessWidget {
  static String name = '/emergency';
  final List<EmergencyContact> contacts = [
    EmergencyContact(
      id: '1',
      name: 'Police',
      phone: '999',
      type: 'Police',
    ),
    EmergencyContact(
      id: '2',
      name: 'Ambulance',
      phone: '199',
      type: 'Ambulance',
    ),
    EmergencyContact(
      id: '3',
      name: 'Fire Service',
      phone: '16163',
      type: 'Fire',
    ),
    // Add more contacts as needed
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Emergency Quick Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildEmergencyButton(
                  context,
                  'Police',
                  Icons.local_police,
                  Colors.blue,
                  '999',
                ),
                _buildEmergencyButton(
                  context,
                  'Ambulance',
                  Icons.medical_services,
                  Colors.red,
                  '199',
                ),
                _buildEmergencyButton(
                  context,
                  'Fire Service',
                  Icons.fire_truck,
                  Colors.orange,
                  '16163',
                ),
                _buildEmergencyButton(
                  context,
                  'Hospital',
                  Icons.local_hospital,
                  Colors.green,
                  '10655',
                ),
              ],
            ),
          ),

          // Emergency Contacts List
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: Icon(_getIconForType(contact.type)),
                  title: Text(contact.name),
                  subtitle: Text(contact.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone),
                    color: Colors.green,
                    onPressed: () => _makePhoneCall(contact.phone),
                  ),
                  onTap: () => _makePhoneCall(contact.phone),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_alert),
        onPressed: () {
          // Add functionality for emergency alert
          _showEmergencyAlertDialog(context);
        },
      ),
    );
  }

  Widget _buildEmergencyButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      String phoneNumber,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _makePhoneCall(phoneNumber),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(phoneNumber, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'police':
        return Icons.local_police;
      case 'ambulance':
        return Icons.medical_services;
      case 'fire':
        return Icons.fire_truck;
      case 'hospital':
        return Icons.local_hospital;
      default:
        return Icons.emergency;
    }
  }

  void _showEmergencyAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: const Text('Send emergency alert to nearby hospitals and contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Implement emergency alert functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency alert sent!')),
              );
            },
            child: const Text('Send Alert', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}