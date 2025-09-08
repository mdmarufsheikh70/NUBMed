import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nubmed/model/user_model.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  late String _chatId;
  late Stream<QuerySnapshot> _messagesStream;
  medUser? _receiverUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Load receiver user first
      await _loadReceiverUser();

      // Setup chat after receiver is loaded
      _chatId = _getChatId(currentUserId, widget.receiverId);

      await _firestore.collection('chats').doc(_chatId).set({
        'participants': [currentUserId, widget.receiverId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _messagesStream = _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReceiverUser() async {
    try {
      final doc = await _firestore.collection('users').doc(widget.receiverId).get();
      if (doc.exists) {
        setState(() {
          _receiverUser = medUser.fromFirestore(doc);
        });
      }
    } catch (e) {
      print('Error loading receiver user: $e');
    }
  }

  String _getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_auth.currentUser == null) return;

    try {
      final currentUserId = _auth.currentUser!.uid;
      final messageText = _messageController.text.trim();
      _messageController.clear();

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update chat document
      await _firestore.collection('chats').doc(_chatId).update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      await _sendPushNotification(messageText);
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  Future<void> _sendPushNotification(String message) async {
    try {
      final receiverDoc = await _firestore.collection('users').doc(widget.receiverId).get();
      final tokens = receiverDoc.data()?['fcmTokens'] as List<dynamic>? ?? [];

      if (tokens.isNotEmpty) {
        await _firestore.collection('notifications').add({
          'to': tokens.first,
          'notification': {
            'title': widget.receiverName,
            'body': message,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'chatId': _chatId,
            'senderId': _auth.currentUser!.uid,
          },
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: _receiverUser?.photoUrl.isNotEmpty == true
                  ? NetworkImage(_receiverUser!.photoUrl)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == _auth.currentUser?.uid;

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final timestamp = message['timestamp'] as Timestamp?;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[500] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 12 : 0),
            topRight: Radius.circular(isMe ? 0 : 12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            if (timestamp != null) ...[
              SizedBox(height: 4),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}