import 'package:flutter/material.dart';
import 'package:nubmed/model/user_model.dart';
import 'package:nubmed/pages/Chat/chat_screen.dart';

class UserDetailsPage extends StatefulWidget {
  final medUser user;
  final String currentUserId;

  const UserDetailsPage({
    super.key,
    required this.user,
    required this.currentUserId,
  });

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.name}\'s Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Profile Image Container
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.user.photoUrl.isNotEmpty
                          ? Image.network(
                        widget.user.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderAvatar(widget.user.name),
                      )
                          : _buildPlaceholderAvatar(widget.user.name),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Name and Basic Info
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.user.studentId,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  if (widget.user.donor)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Blood Donor',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // User Details Section
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(20),
              children: [
                _buildDetailCard(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  items: [
                    _buildDetailRow(Icons.email, 'Email', widget.user.email),
                    _buildDetailRow(Icons.phone, 'Phone', widget.user.phone),
                    _buildDetailRow(Icons.location_on, 'Location', widget.user.location),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  icon: Icons.medical_information,
                  title: 'Medical Information',
                  items: [
                    _buildDetailRow(Icons.bloodtype, 'Blood Group', widget.user.bloodGroup),
                    _buildDetailRow(
                      widget.user.donor ? Icons.check_circle : Icons.cancel,
                      'Donor Status',
                      widget.user.donor ? 'Available' : 'Not Available',
                    ),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: widget.user.id != widget.currentUserId
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToChat(context),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: const Icon(Icons.message_rounded, size: 24),
          label: const Text(
            'Send Message',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildPlaceholderAvatar(String name) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: widget.user.id,
          receiverName: widget.user.name,
        ),
      ),
    );
  }
}