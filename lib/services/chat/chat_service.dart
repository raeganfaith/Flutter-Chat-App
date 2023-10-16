import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/message.dart';

class ChatService extends ChangeNotifier {
  //get instance of auth in the firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //send message
  Future<void> sendMessage(String receiverId, String message) async {
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //create new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    //construct chat room id from current user id and receiver id
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    //add new message to database
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userID, String otherUserId) {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteConversation(String userID, String otherUserId) async {
    try {
      List<String> ids = [userID, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Reference to the chat room document
      DocumentReference chatRoomRef =
          _fireStore.collection('chat_rooms').doc(chatRoomId);

      // Reference to the messages collection inside the chat room document
      CollectionReference messagesRef = chatRoomRef.collection('messages');

      // Get all messages and delete each message document
      QuerySnapshot messagesSnapshot = await messagesRef.get();
      for (QueryDocumentSnapshot messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.delete();
      }

      // Delete the chat room document
      await chatRoomRef.delete();

      print('Conversation deleted successfully.');
    } catch (e) {
      print('Error deleting conversation: $e');
      // Handle the error as per your application's requirement
    }
  }
}
