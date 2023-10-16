import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/components/button.dart';
import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isEditMode = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // If the user is signed out, navigate to the login page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  Widget _buildUserData() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          DocumentSnapshot userSnapshot = snapshot.data!;
          return _userData(userSnapshot);
        } else {
          return const Text('User information not found.');
        }
      },
    );
  }

  Widget _userData(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String? imageName = data['image'];

    if (data['email'] != null) {
      return Column(
        children: [
          SizedBox(
              width: 180,
              height: 180,
              child: imageName != null && imageName.isNotEmpty
                  ? CircleAvatar(
                      backgroundColor: AppColor.white,
                      backgroundImage: NetworkImage(imageName),
                    )
                  : const CircleAvatar(
                      backgroundColor: AppColor.silver,
                      child: Icon(
                        Icons.person,
                        color: AppColor.white,
                      ),
                    )),
          const SizedBox(height: 30),
          MyTextField(
            controller: usernameController,
            hintText: data['username'],
            obscureText: false,
            enabled: isEditMode,
          ),
          const SizedBox(height: 10),
          MyTextField(
            controller: emailController,
            hintText: data['email'],
            obscureText: false,
            enabled: false,
          ),
          const SizedBox(height: 10),
          MyTextField(
            controller: passwordController,
            hintText: '********',
            obscureText: true,
            enabled: isEditMode,
          ),
          const SizedBox(height: 50),
          Button(
            title: isEditMode ? 'Save Profile Details' : 'Edit Profile Details',
            filledIn: true,
            onPressed: updateProfile,
          ),
          Visibility(
            visible: isEditMode,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Button(
                title: 'Cancel',
                filledIn: false,
                onPressed: () {
                  setState(() {
                    isEditMode = !isEditMode;
                  });
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return const Text('User information unavailable.');
    }
  }

  Future<void> updateProfile() async {
    if (isEditMode) {
      try {
        String newUsername = usernameController.text.trim();
        String newPassword = passwordController.text.trim();

        if (newUsername.isNotEmpty) {
          await AuthService().updateProfile(newUsername, newPassword);
        } else if (newPassword.isNotEmpty) {
          await AuthService().updatePasswordOnly(newPassword);
        } else {
          return;
        }

        setState(() {
          isEditMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
          ),
        );
      } catch (e) {
        print('Error updating profile: $e');
        // Handle error and show error message to user if necessary
      }
    } else {
      setState(() {
        isEditMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainOrange,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(
          title: 'Your Profile',
          backButton: true,
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            top: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: _buildUserData(),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
