import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/model/chat_model.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'chat_screen.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<List<Chat>> _chatsStream;

  @override
  void initState() {
    super.initState();
    final currentUserId = _auth.currentUser?.uid ?? '';
    _chatsStream = _createChatsStream(currentUserId);
  }

  Stream<List<Chat>> _createChatsStream(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final chatDocs = snapshot.docs;

      final otherUserIds = chatDocs
          .expand((doc) => (doc.data()['participants'] as List).cast<String>())
          .where((id) => id != currentUserId)
          .toSet()
          .toList();

      if (otherUserIds.isEmpty) return [];

      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: otherUserIds)
          .get();

      final usersMap = {
        for (var doc in usersSnapshot.docs)
          doc.id: {
            'name': doc.data()['name'] ?? 'Unknown',
            'photoUrl': doc.data()['photo_url'],
          }
      };

      return chatDocs.map((doc) {
        final data = doc.data();
        final participants = List<String>.from(data['participants']);
        final otherUserId =
        participants.firstWhere((id) => id != currentUserId);

        return Chat.fromFirestoreData(
          doc,
          currentUserId,
          usersMap[otherUserId]?['name'] ?? 'Unknown',
          usersMap[otherUserId]?['photoUrl'],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.message, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Chat>>(
          stream: _chatsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = snapshot.data!;

            if (chats.isEmpty) {
              return const Center(child: Text('No messages yet'));
            }

            return ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: chat.otherUserPhotoUrl != null
                          ? NetworkImage(chat.otherUserPhotoUrl!)
                          : null,
                      backgroundColor: Color_codes.deep,
                      child: chat.otherUserPhotoUrl == null
                          ? const Icon(Icons.person,
                          size: 28, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      chat.otherUserName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Text(
                      DateFormat('hh:mm a').format(chat.lastMessageTime),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: chat.otherUserId,
                            receiverName: chat.otherUserName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
