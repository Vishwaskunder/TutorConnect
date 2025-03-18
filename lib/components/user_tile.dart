import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap; // Changed onTop to onTap for consistency

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {  // Fixed the method signature
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 25),
        
        padding: EdgeInsets.all(12),
        child: Row(
          children: [  // Fixed the incorrect syntax here
            // Icon
            Icon(Icons.person),
            
            const SizedBox(width: 20,),
            // User name
            Text(text),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// class UserTile extends StatelessWidget{
//   final String text;
//   final void Function()? onTop;
//
//   const UserTile({
//     super.key,
//     required this.text,
//     required this.onTap,
//
//   });
//
//   @override
//   Widget build(buildContext context){
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration : BoxDecoration(
//           color: Theme.of(context).colorScheme.secondary,
//           borderRadius:BorderRadius.circular(12),
//         ),
//
//         child : Row(
//           children:(
//             //Icon
//             Icon(Icons.person),
//             //user name
//             Text(text),
//
//           ),
//         )
//       ),
//
//     );
//   }
// }