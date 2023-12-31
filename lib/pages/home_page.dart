import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/pages/landing_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Landing()),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String? imageName = data['image'];

    // Display all users except the current user
    if (_auth.currentUser!.email != data['email']) {
      return Slidable(
        key: ValueKey(data['uid']),
        endActionPane: ActionPane(
          motion: DrawerMotion(),
          children: [
            SlidableAction(
              icon: Icons.delete,
              backgroundColor: Colors.red,
              onPressed: (context) async {
                bool confirmDelete =
                    await _showDeleteConfirmationModal(context);
                if (confirmDelete) {
                  QuerySnapshot querySnapshot = await _fireStore
                      .collection('users')
                      .where('email', isEqualTo: _auth.currentUser?.email)
                      .get();

                  String userID = querySnapshot.docs.first.id;
                  String otherUserID = data['uid'];

                  // Call the function to delete conversation
                  ChatService chatService = ChatService();
                  await chatService.deleteConversation(userID, otherUserID);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Conversation deleted successfully'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        child: ListTile(
          title: Text(data['username'] ?? 'unknown user'),
          leading: (imageName != null && imageName.isNotEmpty)
              ? CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(imageName),
                )
              : (data['username'] != null && data['username'].isNotEmpty)
                  ? CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors
                          .grey, // Use grey background for users without username
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data['email'],
                  receiverUserID: data['uid'] ?? '',
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Future<bool> _showDeleteConfirmationModal(BuildContext context) async {
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Delete Conversation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Are you sure you want to delete this conversation?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(false); // Dismiss the modal and return false
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(true); // Dismiss the modal and return true
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainOrange,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(
          title: 'Chatter\'s Inbox',
          backButton: false,
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(child: _buildUserList()),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
