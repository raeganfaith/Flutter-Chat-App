import 'dart:typed_data';

import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/utils/image_picker.dart';
import 'package:chat_app/utils/save_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../components/my_text_field.dart';
import '../components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Uint8List? _image;
  // bool _isImageSelected = false;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> _selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
        // _isImageSelected = true;
      });
    } else {
      final ByteData data =
          await rootBundle.load('assets/images/static-profile.png');
      Uint8List defaultImageBytes = data.buffer.asUint8List();
      setState(() {
        _image = defaultImageBytes;
        // _isImageSelected = true;
      });
    }
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        _selectImage(); // Call the asynchronous function directly
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[400],
        backgroundImage: _image != null ? MemoryImage(_image!) : null,
        child: _image == null
            ? Icon(
                Icons.camera_alt,
                size: 40,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  // Widget _profileImageField() {
  //   return GestureDetector(
  //     onTap: () {
  //       _selectImage(); // Call the asynchronous function directly
  //     },
  //     child: CircleAvatar(
  //       radius: 50,
  //       backgroundColor: Colors.grey[400],
  //       backgroundImage: _image != null
  //           ? MemoryImage(_image!)
  //           : AssetImage('assets/images/static-profile.png')
  //               as ImageProvider<Object>,
  //       child: _image == null
  //           ? Icon(
  //               Icons.camera_alt,
  //               size: 40,
  //               color: Colors.white,
  //             )
  //           : null,
  //     ),
  //   );
  // }

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password do not match!"),
        ),
      );
      return;
    }

    String username = usernameController.text;

    // Check if the image and username are selected
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a username"),
        ),
      );
      return;
    }

    if (_image == null) {
      final ByteData data =
          await rootBundle.load('assets/images/static-profile.png');
      _image = data.buffer.asUint8List();
    }

    // Get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      UserCredential userCredential =
          await authService.signUpWithEmailandPassword(
              emailController.text, passwordController.text);

      String uid = userCredential.user!.uid;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String imageName = '$uid-$timestamp.png';

      if (_image != null) {
        String imageUrl = await StoreImage()
            .saveData(uid: uid, imageName: imageName, file: _image!);

        // After creating the user, create a new document for the user in the users collection
        await _fireStore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': emailController.text,
          'username': usernameController.text,
          'image': imageUrl, // Include the image URL in the Firestore document
        });
      } else {
        // Handle the case where _image is null (user didn't select an image)
        // You can show a snackbar or a toast message to inform the user
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating user data: $e'),
        ),
      );
      print('Error creating user data: $e');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  //logo
                  // Icon(
                  //   Icons.message,
                  //   size: 100,
                  //   color: Colors.grey[800],
                  // ),
                  _profileImageField(),

                  const SizedBox(height: 50),

                  //create account message
                  const Text(
                    "Create an Account Here!",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 50),

                  //username textfield
                  MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false),

                  const SizedBox(height: 10),

                  //email textfield
                  MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),

                  const SizedBox(height: 10),

                  //password textfield
                  MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true),

                  const SizedBox(height: 10),

                  //confirm password textfield
                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true),

                  const SizedBox(height: 25),

                  //sign up button
                  MyButton(onTap: signUp, text: "Sign Up"),

                  const SizedBox(height: 50),

                  //not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Sign In Now',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
