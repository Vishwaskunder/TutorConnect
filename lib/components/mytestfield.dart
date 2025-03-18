import 'package:flutter/material.dart';

class Mytestfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const Mytestfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  _MytestfieldState createState() => _MytestfieldState();
}

class _MytestfieldState extends State<Mytestfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,  // Accessing controller using 'widget'
        obscureText: widget.obscureText, // Accessing obscureText using 'widget'
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: widget.hintText, // Accessing hintText using 'widget'
          hintStyle: TextStyle(color: Colors.grey[500]), // Fixed syntax error
        ),
      ),
    );
  }
}




