import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  int _counter = 0;
//  Iterable<Contact> contacts;
  final ContactPicker _contactPicker = new ContactPicker();
  Contact _contact;


  void _incrementCounter() {
//    print(contacts);
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  _getContacts() async {
    PermissionStatus check = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);

    if(check.value == 2) {
      try{
//        Iterable<Contact> cont = await ContactsService.getContacts(withThumbnails: false);
//        setState(() {
//          contacts = cont;
//        });
      } catch(e) {
       print(e.toString());
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
      Contact contact = await _contactPicker.selectContact();
      setState(() {
        _contact = contact;
        });},
        tooltip: 'Increment',
        child: Icon(Icons.message),
      ),
    );
  }
}
