import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency Hotline Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Emergency Hotlines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildContactTile(
                    context,
                    "Police",
                    "999",
                    Icons.local_police,
                    Colors.blue,
                  ),
                  _buildContactTile(
                    context,
                    "Ambulance",
                    "199",
                    Icons.medical_services,
                    Colors.red,
                  ),
                  _buildContactTile(
                    context,
                    "Fire Service",
                    "16163",
                    Icons.fire_truck,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Hospital Support Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Hospital Support",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildContactTile(
                    context,
                    "Main Hospital",
                    "+880 1234 567890",
                    Icons.local_hospital,
                    Colors.green,
                  ),
                  _buildContactTile(
                    context,
                    "Emergency Ward",
                    "+880 9876 543210",
                    Icons.emergency,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Email Support Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Email Support",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text("General Support"),
                    subtitle: const Text("support@nubmed.com"),
                    onTap: () => _launchEmail("support@nubmed.com"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text("Technical Issues"),
                    subtitle: const Text("abiralmuradnub@gmail.com"),
                    onTap: () => _launchEmail("abiralmuradnub@gmail.com"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
      BuildContext context,
      String title,
      String number,
      IconData icon,
      Color color,
      ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(number),
      trailing: IconButton(
        icon: const Icon(Icons.phone, color: Colors.green),
        onPressed: () => _makePhoneCall(number),
      ),
      onTap: () => _makePhoneCall(number),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove all non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not call $cleanNumber")),
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch email client")),
      );
    }
  }
}