import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/pages/Chat/inbox.dart';
import 'package:nubmed/pages/HomePage.dart';
import 'package:nubmed/pages/Profile.dart';
import 'package:nubmed/pages/Notification/notifications_page.dart';
import 'package:nubmed/pages/Search/search_page.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/fetchImage.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  static const String name = '/widget-tree';

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _currentIndex = 0;
  String? _photoUrl;
  bool _isLoading = true;
  String? _error;
  final List<Widget> _screens = [
    const Homepage(),
    const SearchPage(),
    const InboxPage(),
    const NotificationsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final photoUrl = await FetchImage.fetchImageUrl(uid);
      setState(() {
        _photoUrl = photoUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile image';
        _isLoading = false;
      });
      debugPrint('Error loading profile: $e');
    }
  }

  Widget _buildProfileAvatar() {
    if (_isLoading) {
      return const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Profile()),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.greenAccent, Colors.cyan],
          ),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: _photoUrl?.isNotEmpty == true
                ? Image.network(_photoUrl!,
              fit: BoxFit.cover,
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
            )
                : _buildDefaultAvatar(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      size: 24,
      color: Colors.blueGrey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/logo_updated.png",height: 150,width: 200,alignment: Alignment.centerLeft,),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildProfileAvatar(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Color_codes.meddle,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      onTap: (index) => setState(() => _currentIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.messenger_outline),
          activeIcon: Icon(Icons.messenger),
          label: "Inbox",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: "Notifications",
        ),
      ],
    );
  }
}