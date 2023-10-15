import 'package:chat_app/constants/colors.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String title;
  final bool filledIn;
  final Function()? onPressed;

  const Button({
    Key? key,
    required this.title,
    required this.filledIn,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: filledIn
              ? MaterialStateProperty.all<Color>(AppColor.mainOrange)
              : MaterialStateProperty.all<Color>(AppColor.white),
          side: filledIn ? null
              : MaterialStateProperty.all<BorderSide>(
                  const BorderSide(color: AppColor.mainOrange, width: 2.5),
                ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16,
                color: filledIn ? AppColor.white : AppColor.mainOrange,
                fontWeight: FontWeight.bold,
                fontFamily: 'KronaOne'
              ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String title;
  final Function()? onPressed;

  const SecondaryButton({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColor.black),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                color: AppColor.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'KronaOne'
              ),
          ),
        ),
      ),
    );
  }
}
