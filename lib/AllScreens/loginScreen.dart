import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_uber/AllScreens/mainscreen.dart';
import 'package:my_uber/AllScreens/registrationScreen.dart';
import 'package:my_uber/AllWidgets/progressDialog.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
static const String idScreen = "login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
TextEditingController emailTextEditingController= TextEditingController();

 TextEditingController passwordTextEditingController= TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 35.0,
              ),
              Image(
                image: AssetImage("images/logo.png"),
                width: 250.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                "Login as Rider",
                style: TextStyle(fontSize: 26.0),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        errorText: "Enter your Email",
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        errorText: "Enter Your Password",
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (!emailTextEditingController.text.contains("@")){
                          displayToastMessage("Enter valid email", context);
                        }
                         if (passwordTextEditingController.text.isEmpty){
                          displayToastMessage("Password is needed ", context);
                        }
                        else {
                        loginAndAuthenticateUser(context);
                        }
                      },
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Login",
                          ),
                        ),
                      ),
                      style:ElevatedButton.styleFrom(
                primary: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
                textStyle: TextStyle(
                    fontSize: 30,
                  
                    fontWeight: FontWeight.bold)
                    ),
                    ),


                    SizedBox(
                      height: 4.0,
                    ),
                    TextButton(
                      onPressed: () {
                        
                        Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);
                      },
                      style: TextButton.styleFrom(
                         textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold)
                      ),
                      child: Text("Don't Have an Account? Click Here"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async{
  
  showDialog(
    context: context, 
    barrierDismissible: false,
    builder: (BuildContext context)

    {
     return ProgressDialog (message: "Authenticating, please wait...",);
    }
    
    );

  final User? user  = (await _firebaseAuth
    .signInWithEmailAndPassword
    (
      email: emailTextEditingController.text, 
      password: passwordTextEditingController.text)
      .catchError((errMsg){
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
      }))
      .user;

      if (user !=null){//user has signed succesfully with email and password
        //user info is saved
        usersRef.child(user.uid).once().then((DataSnapshot snap){
          if(snap.value != null){
            Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
            displayToastMessage("Logged in succesfully", context);
          }
          else{
            Navigator.pop(context);
            _firebaseAuth.signOut();
            displayToastMessage("your email and password do not exist. Please create a new account", context);
          }
        });
        
      }
      else{
        Navigator.pop(context);
        //error has occured
        displayToastMessage("There is a mistake, you can not be signed in", context);
      }
  }
}
