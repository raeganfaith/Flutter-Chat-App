import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/components/button.dart';
import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isEditMode = false;

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
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 180,
                            height: 180,
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/images/static-profile.png'),
                            ),
                          ),
                          const SizedBox(height: 30),
                          MyTextField(
                            controller: usernameController,
                            hintText: 'Username',
                            obscureText: false,
                            enabled: isEditMode,
                          ),
                          const SizedBox(height: 10),
                          MyTextField(
                            controller: usernameController,
                            hintText: 'Email',
                            obscureText: false,
                            enabled: false,
                          ),
                          const SizedBox(height: 10),
                          MyTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            obscureText: false,
                            enabled: isEditMode,
                          ),
                          const SizedBox(height: 50),
                          Button(
                            title: isEditMode ? 'Save Profile Details' : 'Edit Profile Details',
                            filledIn: true,
                            onPressed: () {
                              setState(() {
                                isEditMode = !isEditMode;
                              });
                            },
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
                      )
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
