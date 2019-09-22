import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ymi_chat_app/models/user.dart';

class UserController {
  static Firestore fireStore = Firestore.instance;
  static User user;

  static open() async {
    user = await getUser();
  }

  static Future<User> getUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      return null;
    }
    return User(user.email, user.uid, true);
  }

  static Future<User> findUser(name) async {
    Iterable<Contact> contacts = await ContactsService.getContacts(query : name);
    String email = "";

    User user;

    if (contacts != null) {
      for (var cont in contacts) {
        for(var e in cont.emails) {
          email = e.value;
        }
      }

      if(email != "") {
        var document = fireStore.collection('users').document(email);
        DocumentSnapshot documentSnapshot = await document.get();
        if(documentSnapshot.exists){
          Map<dynamic, dynamic> map = new Map();
          map = documentSnapshot.data;
          print(map);
          user = User(map["email"], map["id"], map["isActive"]);
        }
      }
      else return null;
    }

    return user;
//    return User(user.email, user.uid, true);
  }

  static Future<List<User>> getActiveUsers() async {
    print("Active Users");
    var val = await fireStore
        .collection("users")
        .getDocuments();
    var documents = val.documents;
    print("Documents ${documents.length}");
    if (documents.length > 0) {
      try {
        print("Active ${documents.length}");
        return documents.map((document) {
          User user = User.fromJson(Map<String, dynamic>.from(document.data));
          print("User ${user.email}");
          return user;
        }).toList();
      } catch (e) {
        print("Exception $e");
        return [];
      }
    }
    return [];
  }

}

/*
* document.get()
            .then(
                (docSnapshot) => {
                  if (docSnapshot.exists) {
                    print(docSnapshot);
                    user = new User(docSnapshot.data.email, docSnapshot.data.id, docSnapshot.data.isActive);
                  }
                  else {
                    print("not found!")
                  }
                }
            );
*
*
* */

