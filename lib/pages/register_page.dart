import 'package:chat_app/components/button.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/pages/landing_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/utils/image_picker.dart';
import 'package:chat_app/utils/save_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../components/my_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
      // final ByteData data =
      //     await rootBundle.load('assets/images/static-profile.png');
      // Uint8List defaultImageBytes = data.buffer.asUint8List();
      // setState(() {
      //   _image = defaultImageBytes;
      // _isImageSelected = true;
      // });
      return;
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
            ? const Icon(
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

    // Check if the image and username are selected
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a username"),
        ),
      );
      return;
    }

    // if (_image == null) {
    //   final ByteData data =
    //       await rootBundle.load('assets/images/static-profile.png');
    //   _image = data.buffer.asUint8List();
    // }

    // Get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      UserCredential userCredential =
          await authService.signUpWithEmailandPassword(
              emailController.text, passwordController.text);

      String uid = userCredential.user!.uid;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String imageName = '$uid-$timestamp.png';

      String imageUrl = ''; // Default value is an empty string

      if (_image != null) {
        imageUrl = await StoreImage()
            .saveData(uid: uid, imageName: imageName, file: _image!);
      }

      // Create a new document for the user in the users collection
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': emailController.text,
        'username': usernameController.text,
        'image': imageUrl, // Include the image URL in the Firestore document
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registered successfully'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColor.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Landing()),
                        );
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: 50,
                          height: 50,
                          color: AppColor.mainOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CREATE\nACCOUNT",
                      style: TextStyle(
                          fontSize: 35,
                          color: AppColor.mainOrange,
                          fontFamily: 'KronaOne'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "We're happy to see you here!",
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColor.mainOrange,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _profileImageField(),
                    const SizedBox(height: 20),
                    MyTextField(
                        controller: usernameController,
                        hintText: 'Username',
                        obscureText: false),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true),
                    const SizedBox(height: 10),
                    MyTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true),
                    const SizedBox(height: 40),
                    Button(
                      title: 'Register',
                      filledIn: true,
                      onPressed: signUp,
                    ),
                    const SizedBox(height: 35),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                              style: TextStyle(
                                fontFamily: 'JosefinSans',
                                color: AppColor.black,
                                fontSize: 16,
                              ),
                              text: "Already have an account? "),
                          TextSpan(
                              style: const TextStyle(
                                fontFamily: 'JosefinSans',
                                color: AppColor.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              text: 'Sign In Now',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()));
                                })
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
