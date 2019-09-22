import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ymi_chat_app/constants/custom_color.dart';
import 'package:ymi_chat_app/screens/chats.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {

  TabController _tabController;

  Map<String, String> creds = {};
  String errorMSG = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();

    getUser().then(
        (user) {
          if(user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Chats(),
              ),
            );
          }
        }
    );
  }

  void setCreds(String type, String value) {
    setState(() {
      creds[type] = value;
    });
    if (errorMSG != "")
      setState(() {
        errorMSG = "";
      });
  }

  Widget messageTextComponent(text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget errorMessageComponent(msg) {
    return Text(
      msg,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.red),
    );
  }

  Widget textFieldComponent(
      {String hintText, @required String type, bool obscure = false}) {
    return Container(
      height: 55,
      margin: EdgeInsets.only(left: 30, right: 30),
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: TextField(
          obscureText: obscure,
          onChanged: (value) => setCreds(type, value),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText ?? "",
          ),
        ),
      ),
    );
  }

  void signUp(String email, String pass) async {
    AuthResult result;
    FirebaseUser user;

    try {
      result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: pass
      );

      user = result.user;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Chats(),
        ),
      );

    } catch (e) {
      setState(() {
        errorMSG = e.message;
      });
    } finally {
      if(user != null) {
        print(user);
      }
      else {
        print("Error in authentication");
      }
    }
  }

  void logIn(String email, String pass) async {
    AuthResult result;
    FirebaseUser user;

    try {
      result = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      user = result.user;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Chats(),
        ),
      );

    } catch(e) {
      print(e.toString());
      setState(() {
        errorMSG = e.message;
      });
    } finally {
      print("Error in authentication");
    }
  }

  Widget submitButton(String submitType) {
    return GestureDetector(
      onTap: () {
        String email = creds["email"] ?? "";
        String pass = creds["password"] ?? "";
        if (email != "" && pass != "") {
          signUp(email, pass);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 30, right: 30),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: MaterialColor(0xFFFF5900, color),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              color: Colors.deepOrange,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Center(
          child: Text(
            submitType,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("YMI CHAT APP"),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.black38,
          tabs: [
            new Tab(icon: new Text("Signup")),
            new Tab(
              icon: new Text("Login"),
            ),
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
      ),
      body: TabBarView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              messageTextComponent("Sign up to continue"),
              Container(margin: EdgeInsets.only(top: 35)),
              textFieldComponent(type: "email", hintText: "Email Address"),
              Container(margin: EdgeInsets.only(top: 20)),
              textFieldComponent(
                type: "password",
                hintText: "Password",
                obscure: true,
              ),
              Container(margin: EdgeInsets.only(top: 20)),
              errorMessageComponent(errorMSG),
              Container(margin: EdgeInsets.only(top: 20)),
              submitButton("Sign Up")
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              messageTextComponent("Log In"),
              Container(margin: EdgeInsets.only(top: 35)),
              textFieldComponent(type: "email", hintText: "Email Address"),
              Container(margin: EdgeInsets.only(top: 20)),
              textFieldComponent(
                type: "password",
                hintText: "Password",
                obscure: true,
              ),
              Container(margin: EdgeInsets.only(top: 20)),
              errorMessageComponent(errorMSG),
              Container(margin: EdgeInsets.only(top: 20)),
              submitButton("Log In")
            ],
          )
        ],
        controller: _tabController,
      ),
    );
  }
}

/*
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Phone number';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState.validate()) {
                            // Process data.
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              )
 */
