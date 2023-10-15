import 'package:chat_app/components/button.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../components/my_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password do not match!"),
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailandPassword(
          emailController.text, passwordController.text);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        color: AppColor.black,
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
                      color: AppColor.mainOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "CREATE\nACCOUNT",
                  style: TextStyle(
                      fontSize: 35,
                      color: AppColor.mainOrange,
                      fontFamily: 'KronaOne'
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We're happy to see you here!",
                  style: TextStyle(
                      fontSize: 20,
                      color: AppColor.mainOrange,
                  ),
                ),
                const SizedBox(height: 50),
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
                const SizedBox(height: 15),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true
                ),
                const SizedBox(height: 40),
                Button(
                  title: 'Register',
                  filledIn: true,
                  onPressed: signUp,
                ),
                const SizedBox(height: 80),
                Center(
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
                        recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                          }
                      )
                    ]),
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
