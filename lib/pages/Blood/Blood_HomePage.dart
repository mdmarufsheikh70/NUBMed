import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nubmed/pages/Blood/Blood_page.dart';
import 'package:nubmed/utils/blood_group_class.dart';

class BloodHomepage extends StatefulWidget {
  const BloodHomepage({super.key});

  @override
  State<BloodHomepage> createState() => _BloodHomepageState();
}

class _BloodHomepageState extends State<BloodHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Find Blood Donors'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('donor', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return _buildErrorState();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                  children: Blood_Group_class.bloodGroups.map((bloodGroup) {
                    final count = donorCount(snapshot.data!, bloodGroup);
                    return _BloodTypeCard(
                      bloodGroup: bloodGroup,
                      donorCount: count,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BloodPage(bloodtype: bloodGroup),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int donorCount(QuerySnapshot snapshot, String bloodGroup) {
    return snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['blood_group'] == bloodGroup;
    }).length;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Failed to load data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Please check your connection',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => setState(() {}),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.red),
          ),
          const SizedBox(height: 20),
          Text(
            'Finding donors...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bloodtype, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'No donors available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Check back later or register as donor',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _BloodTypeCard extends StatelessWidget {
  final String bloodGroup;
  final int donorCount;
  final VoidCallback onTap;

  const _BloodTypeCard({
    required this.bloodGroup,
    required this.donorCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Blood drop with type
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getColorForBloodGroup(bloodGroup).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  bloodGroup,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _getColorForBloodGroup(bloodGroup),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Blood type label
            Text(
              bloodGroup,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // Donor count
            Chip(
              backgroundColor: donorCount > 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: donorCount > 0 ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$donorCount ${donorCount == 1 ? 'donor' : 'donors'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: donorCount > 0 ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getColorForBloodGroup(String bloodGroup) {
    const colors = {
      'A+': Color(0xFFE53935),
      'A-': Color(0xFFD81B60),
      'B+': Color(0xFF3949AB),
      'B-': Color(0xFF8E24AA),
      'AB+': Color(0xFF5E35B1),
      'AB-': Color(0xFF4527A0),
      'O+': Color(0xFFF57C00),
      'O-': Color(0xFFEF6C00),
    };
    return colors[bloodGroup] ?? Colors.red;
  }
}