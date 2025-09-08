import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  Chat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  // Synchronous factory when you already have all data
  factory Chat.fromFirestoreData(
      DocumentSnapshot doc,
      String currentUserId,
      String otherUserName,
      String? otherUserPhotoUrl,
      ) {
    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants']);
    final otherUserId = participants.firstWhere((id) => id != currentUserId);

    return Chat(
      chatId: doc.id,
      participants: participants,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl,
    );
  }

  // Asynchronous factory when you need to fetch user data
  static Future<Chat> fromFirestore(DocumentSnapshot doc, String currentUserId) async {
    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participants']);
    final otherUserId = participants.firstWhere((id) => id != currentUserId);

    final otherUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();

    return Chat.fromFirestoreData(
      doc,
      currentUserId,
      otherUserDoc['name'] ?? 'Unknown',
      otherUserDoc['photoUrl'],
    );
  }
}