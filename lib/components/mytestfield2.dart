import 'package:flutter/material.dart';

class Mytestfield2 extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;

  const Mytestfield2({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.focusNode,
  });

  @override
  _Mytestfield2State createState() => _Mytestfield2State();
}

class _Mytestfield2State extends State<Mytestfield2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,  // Accessing controller using 'widget'
        obscureText: widget.obscureText, // Accessing obscureText using 'widget'
        focusNode: widget.focusNode,  // Corrected this line
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


// import 'package:flutter/material.dart';

// class Mytestfield2 extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final bool obscureText;

//   final FocusNode ? focusNode;

//   const Mytestfield2({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     required this.obscureText,
//     this.focusNode,
//   });

//   @override
//   _Mytestfield2State createState() => _Mytestfield2State();
// }

// class _Mytestfield2State extends State<Mytestfield2> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//       child: TextField(
//         controller: widget.controller,  // Accessing controller using 'widget'
//         obscureText: widget.obscureText, // Accessing obscureText using 'widget'
//         focusNode: focusNode,
//         decoration: InputDecoration(
//           enabledBorder: const OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.white),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey.shade400),
//           ),
//           fillColor: Colors.grey.shade200,
//           filled: true,
//           hintText: widget.hintText, // Accessing hintText using 'widget'
//           hintStyle: TextStyle(color: Colors.grey[500]), // Fixed syntax error
//         ),
//       ),
//     );
//   }
// }




