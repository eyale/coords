import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  String title;
  IconData iconName;
  final VoidCallback handleTap;

  CustomIconButton({
    Key? key,
    required this.title,
    required this.handleTap,
    required this.iconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          iconName,
          size: 20,
          color: Colors.white,
        ),
        label: Text(title),
        onPressed: handleTap,
      ),
    );
  }
}
