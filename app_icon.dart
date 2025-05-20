import 'package:flutter/material.dart';
import 'dart:io';

class AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Icon(
          Icons.smart_toy_rounded,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}
