import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutorconnect_app/components/chat_bubble.dart';
// import 'package:tutorconnect_app/models/messsage.dart';
import 'package:tutorconnect_app/services/auth/auth_service.dart';
import 'package:tutorconnect_app/services/chat/chat_service.dart';
import 'package:tutorconnect_app/components/mytestfield2.dart';

class ChatPage2 extends StatefulWidget{
  final String receiverEmail;
  final String receiverID;
  ChatPage2({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage2> createState() => _ChatPage2State();
}

class _ChatPage2State extends State<ChatPage2> {
  //text controller
  final  TextEditingController _messageController=TextEditingController();

  // chat & auth services 
  final ChatService _chatService= ChatService();
  final AuthService _authService=AuthService();

  //for textfield focus
  FocusNode myFocusNode=FocusNode();

  @override  
  void initState(){
    super.initState();

    //add listener to focus node
    myFocusNode.addListener((){
      if (myFocusNode.hasFocus){
        // to cause a delay so that the keyboard has time to show up
        // then the amount of remaining space will be calculated
        // then scroll down

        Future.delayed(
          const Duration(microseconds: 500),
          ()=> scrollDown(),
          
        );
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(
      const Duration(microseconds: 500),
      ()=>scrollDown(),
    );
  }

  @override  
  void dispose(){
    super.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController =ScrollController();
  void scrollDown(){
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration:const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn, 
    );
  }


  //Send message
  void sendMessage() async{
    // if there is somethings inside the textfield

    if(_messageController.text.isNotEmpty){
      //send the message
      await _chatService.sendMessage(widget.receiverID, _messageController.text);


      // clear text controller
      _messageController.clear();


    }

    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
         backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildUserInput(),
        ],
      ),

    );
  }

  // build message list
  Widget _buildMessageList(){
    String senderID=_authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream:_chatService.getMessages(widget.receiverID, senderID) ,
       builder: (context,snpshot){
        // errors 
        if(snpshot.hasError){
          return const Text("Error");
        }

        // loading
        if(snpshot.connectionState==ConnectionState.waiting){
          return const Text("Loading..");
        }

        // return list view
        return ListView(
          controller: _scrollController,
          children: snpshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );

       },
     );
  }

  // build messages item
  Widget _buildMessageItem(DocumentSnapshot doc){
    Map<String,dynamic> data = doc.data() as Map<String,dynamic>;

    //is current user
    bool isCurrentUser =data['senderID']==_authService.getCurrentUser()!.uid;

    // align message to the right if sender is the current user,otherwise left
    var alignment= isCurrentUser? Alignment.centerRight:Alignment.centerLeft;

   
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children :[ 
         ChatBubble(
          message: data["message"],
           isCurrentUser: isCurrentUser
          )
        ])
      );

  }

  // build message input
  Widget _buildUserInput(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // textfield should take up most of the space 
          Expanded(
            child: Mytestfield2(
              controller:_messageController,
              hintText: "Type a message",
              obscureText: false,
              focusNode:myFocusNode,
            ),
            
          ),
      
          // send  butoon
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
      
        ],
      ),
    );
  }
}