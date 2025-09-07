import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nubmed/model/user_model.dart';
import 'package:nubmed/pages/Details/user_details_page.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodPage extends StatefulWidget {
  final String bloodtype;

  const BloodPage({super.key, required this.bloodtype});

  @override
  State<BloodPage> createState() => _BloodPageState();
}

class _BloodPageState extends State<BloodPage> {
  Future<void> _makePhoneCall(String number) async {
    if (number.isEmpty) {
      _showSnackBar('No phone number available');
      return;
    }

    try {
      final Uri launchUri = Uri(scheme: 'tel', path: number);
      await Clipboard.setData(ClipboardData(text: number));

      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showSnackBar('Could not launch phone call to $number');
      }
    } on PlatformException catch (e) {
      _showSnackBar('Error: ${e.message}');
    } catch (e) {
      _showSnackBar('An unexpected error occurred');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDonorItem(medUser user) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>UserDetailsPage(user: user, currentUserId: FirebaseAuth.instance.currentUser!.uid)));
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.cyan.shade50,
                child: user.photoUrl.isEmpty
                    ? Icon(
                  Icons.person,
                  color: Color_codes.deep,
                  size: 28, // Match the radius size
                )
                    : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.photoUrl,
                    fit: BoxFit.cover,
                    width: 56,
                    height: 56,
                    placeholder: (context, url) => CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.pinkAccent,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: Colors.cyan[100],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.location.isNotEmpty)
                      Text(
                        "Location: ${user.location}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    if (user.phone.isNotEmpty)
                      Text(
                        user.phone,
                        style: const TextStyle(fontSize: 15),
                      ),
                    if (user.email.isNotEmpty)
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user.bloodGroup,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text("Call"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color_codes.deep_plus,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 0,
                    ),
                    onPressed: () => _makePhoneCall(user.phone),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bloodtype, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            "No ${widget.bloodtype} Donors Found",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later or contact support",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.bloodtype} Donors"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('blood_group', isEqualTo: widget.bloodtype)
              .where('donor', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      "Failed to load donors",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final donors = snapshot.data!.docs;

            return ListView.builder(
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];
                final meduserData = medUser.fromFirestore(donor);
                return _buildDonorItem(meduserData);
              },
            );
          },
        ),
      ),
    );
  }
}