import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ymi_chat_app/controllers/chats_controller.dart';
import 'package:ymi_chat_app/controllers/user_controller.dart';
import 'package:ymi_chat_app/models/chat.dart';
import 'package:ymi_chat_app/models/user.dart';
import 'package:ymi_chat_app/screens/chat.dart';
import 'package:ymi_chat_app/widgets/chat_item.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {

  Map<PermissionGroup, PermissionStatus> _permissions;
  final ContactPicker _contactPicker = new ContactPicker();
  Contact _contact;


  void _incrementCounter() async {

    PermissionStatus check = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    if(check.value == 2) {
      _getContact();
    }
  }

  _getContact() async {
    Contact contact = await _contactPicker.selectContact();
    if(contact != null) {
      User cont = await UserController.findUser(contact.fullName);
      if(cont != null) {
        print(cont);
        bool sent = await ChatsController.sendMessage(
          Chat.fromNamed(
              from: await UserController.getUser(),
              to: cont,
              content: "",
              publishedAt: DateTime.now()
          )
        );

        if(sent) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ChatScreen(friend: cont)));
        }
      }
      else {
        _neverSatisfied(contact.fullName);
      }
    }
  }

  Future<void> _neverSatisfied(String name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not a YMI CHAT APP User'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${name}\'s email is not registered with YMI CHAT APP'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getPermission () async {

    PermissionStatus check = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    if(check.value != 2) {
      Map<PermissionGroup, PermissionStatus> perm = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
      setState(() {
        _permissions = perm;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
      ),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            stream: ChatsController.getChats(),
            builder: (context,snapshot){
              if(!snapshot.hasData){
                return Center(child: CircularProgressIndicator(),);
              }
              List<Chat>chats=snapshot.data;
              return ListView.builder(
                itemBuilder: (context, index) =>RecentChatWidget(
                  chat: chats[index],
                ),
                itemCount:chats.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'New conversation',
        child: Icon(Icons.message),
      ),
    );
  }
}
