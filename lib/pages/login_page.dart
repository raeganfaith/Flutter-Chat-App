import 'package:chat_app/components/my_text_field.dart';
import 'package:chat_app/components/button.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign in user
  Future<void> signIn() async {
    //get Auth Service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailandPassword(
          emailController.text, passwordController.text);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainOrange,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColor.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 50,
                      height: 50,
                      color: AppColor.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "WELCOME\nBACK!",
                  style: TextStyle(
                      fontSize: 35,
                      color: AppColor.white,
                      fontFamily: 'KronaOne'
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your email and password\nto sign in.",
                  style: TextStyle(
                      fontSize: 20,
                      color: AppColor.white,
                  ),
                ),
                const SizedBox(height: 70),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true
                ),
                const SizedBox(height: 40),
                SecondaryButton(
                  title: 'Log In',
                  onPressed: signIn,
                ),
                const SizedBox(height: 80),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            style: TextStyle(
                              fontFamily: 'JosefinSans',
                              color: AppColor.white,
                              fontSize: 16,
                            ),
                            text: "Not a member? "),
                        TextSpan(
                          style: const TextStyle(
                            fontFamily: 'JosefinSans',
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          text: 'Register Now',
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                          }
                        )
                      ]
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
