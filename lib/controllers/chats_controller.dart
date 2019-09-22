import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ymi_chat_app/controllers/user_controller.dart';
import 'package:ymi_chat_app/models/chat.dart';
import 'package:ymi_chat_app/models/user.dart';


class ChatsController {
  static const String CHATS="chats",RECENT="recentChats",MESSAGES="messages";

  static Stream<List<Chat>> getChats() async*{
    Firestore firestore=Firestore.instance;
    User user= await UserController.getUser();
    List<User>activeUsers=await UserController.getActiveUsers();
    await for(QuerySnapshot snap in firestore.collection(RECENT).document(user.email).collection("history").snapshots()){
      try{
//        List<Chat>chats=snap.documents.map((doc)=>Chat.fromJson(Map<String,dynamic>.from(doc.data))).toList();
        List<Chat>chats = snap.documents.map((doc)=>Chat.fromNamed(
            content: doc.data["content"],
            from: User.fromNamed(email: doc.data["from"]["email"], id: doc.data["from"]["id"], isActive: doc.data["from"]["isActive"]),
            to: User.fromNamed(email: doc.data["to"]["email"], id: doc.data["to"]["id"], isActive: doc.data["to"]["isActive"]),
            publishedAt: DateTime.parse(doc.data["publishedAt"]),
            groupId: doc.data["groupId"],
            type: doc.data["type"]
        )).toList();
        chats.forEach((chat){
          chat.to.isActive=false;
          chat.from.isActive=false;
          if(chat.to.email != user.email){
            activeUsers.forEach((temp){
              if(temp.email==chat.to.email){
//                chat.to.isActive=true;
              }
            });
          }
          else{
            activeUsers.forEach((temp){
              if(temp.email == chat.from.email){
                chat.from.isActive=true;
              }
            });
          }
        });
        yield chats;
      }
      catch(e){
        print(e);
      }
    }
  }
  static Future<bool> sendMessage(Chat chat)async{
    try{
      Firestore fireStore=Firestore.instance;
      String id=getUniqueId(chat.from.email, chat.to.email);
      print("ID $id");
      chat.groupId=id;
      fireStore.collection(MESSAGES).add(chat.toJson());
      await saveRecentChat(chat);
      return true;
    }
    catch(e){
      print("Exception $e");
      return false;
    }
  }
  static Future saveRecentChat(Chat chat)async{
    List<String>ids=[chat.from.email,chat.to.email];
    for(String id in ids){
      Firestore fireStore=Firestore.instance;
      Query query=fireStore.collection(RECENT).document(id).collection("history").where("groupId",isEqualTo: getUniqueId(chat.from.email, chat.to.email));
      QuerySnapshot  documents=await query.getDocuments();
      if(documents.documents.length!=0){
        DocumentSnapshot documentSnapshot=documents.documents[0];
        documentSnapshot.reference.setData(chat.toJson());
      }
      else{
        fireStore.collection(RECENT).document(id).collection("history").add(chat.toJson());
      }
    }
  }
  static String getUniqueId(String i1,String i2){
    if(i1.compareTo(i2)<=-1){
      return i1+i2;
    }
    else{
      return i2+i1;
    }
  }
  static Stream<List<Chat>> listenChat(User from,User to)async*{
    Firestore firestore=Firestore.instance;
    await for(QuerySnapshot snap in firestore.collection("messages").where("groupId",isEqualTo: getUniqueId(from.email,to.email,)).snapshots()){
      try{
        List<Chat> chats = snap.documents.map((doc)=> Chat.fromNamed(
                content: doc.data["content"],
                from: User.fromNamed(email: doc.data["from"]["email"], id: doc.data["from"]["id"], isActive: doc.data["from"]["isActive"]),
                to: User.fromNamed(email: doc.data["to"]["email"], id: doc.data["to"]["id"], isActive: doc.data["to"]["isActive"]),
                publishedAt: DateTime.parse(doc.data["publishedAt"]),
                groupId: doc.data["groupId"],
                type: doc.data["type"]
            )
        ).where((c) => c.content != "").toList().reversed.toList();
        yield chats;
      }
      catch(e){
        print(e);
      }
    }
  }
  static String filterVal(String val){
    List<String>inCorrects=[":","#","\$","[","]","."];
    String filtered=val;
    inCorrects.forEach((val){
      filtered=filtered.replaceAll(val, "");
    });
    return filtered;
  }
}