import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/pages/landing_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget {
  final String title;
  // final Color? appBarColor;
  final bool backButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    // required this.appBarColor,
    required this.backButton,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Landing()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.mainOrange,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.backButton,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColor.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: AppColor.white,
                  fontFamily: 'KronaOne',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const Spacer(),
            PopupMenuButton(
              icon: const Icon(Icons.menu_rounded, color: AppColor.white),
              elevation: 10,
              color: AppColor.white,
              offset: Offset(0.0, AppBar().preferredSize.height),
              onSelected: (tapped) {
                if (tapped == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                } else {
                  signOut();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 0,
                  child: Text('Profile'),
                ),
                const PopupMenuItem(
                  value: 1,
                  child: Text('Log out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
