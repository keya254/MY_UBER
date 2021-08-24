import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_uber/AllScreens/loginScreen.dart';
import 'package:my_uber/AllScreens/mainscreen.dart';
import 'package:my_uber/AllWidgets/progressDialog.dart';
import 'package:my_uber/main.dart';

class RegistrationScreen extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameTextEditingController= TextEditingController();

  TextEditingController emailTextEditingController= TextEditingController();

  TextEditingController phoneTextEditingController= TextEditingController();

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
                height: 20.0,
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
                "Register as Rider",
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
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Name",
                        errorText: "Enter Your Name",
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
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Phone",
                        errorText: "Enter Your Phone Number",
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
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter Email",
                        errorText: "Enter Your Email",
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
                        if(nameTextEditingController.text.length < 4)
                        {
                          displayToastMessage("Name must be atleast 4 Characters", context);
                        }
                        else if (!emailTextEditingController.text.contains("@")){
                          displayToastMessage("Enter valid email", context);
                        }
                        else if (phoneTextEditingController.text.length<10){
                          displayToastMessage("Enter valid phone number", context);
                        }
                        else if (passwordTextEditingController.text.length<8){
                          displayToastMessage("Password must be atleast 8 characters", context);
                        }
                        else{
                          registerNewUser(context);
                        }
                        
                      },
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Create Account",
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.yellow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          textStyle: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    TextButton(
                      onPressed: () {
                         Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                      },
                      style: TextButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      child: Text("Already Have an Account? Login Here"),
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

  void registerNewUser(BuildContext context) async {
  showDialog(
    context: context, 
    barrierDismissible: false,
    builder: (BuildContext context)

    {
     return ProgressDialog (message: "Registering, please wait...",);
    }
    
    );

    final User? user  = (await _firebaseAuth
    .createUserWithEmailAndPassword(
      email: emailTextEditingController.text, 
      password: passwordTextEditingController.text)
      .catchError((errMsg){
       Navigator.pop(context); 
      displayToastMessage("Error: " + errMsg.toString(), context);
      }))
      .user;

      if (user !=null){//user is created
        //user info is saved
        
        Map userDataMap = {
          "name":nameTextEditingController.text.trim(),
          "email":emailTextEditingController.text.trim(),
          "phone":phoneTextEditingController.text.trim(),
        };
        usersRef.child(user.uid).set(userDataMap);
        displayToastMessage("Congratulation, your account has been created", context);

        Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
      }
      else{
        //error has occured
        Navigator.pop(context);
        displayToastMessage("New user Account has not been created", context);
      }
  }
  
}
displayToastMessage(String message, BuildContext context){
    Fluttertoast.showToast(msg:message);
  }