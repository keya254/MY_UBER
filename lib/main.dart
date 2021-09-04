import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_uber/AllScreens/loginScreen.dart';
import 'package:my_uber/AllScreens/mainscreen.dart';
import 'package:my_uber/AllScreens/registrationScreen.dart';
import 'package:my_uber/DataHandler/appData.dart';
import 'package:provider/provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi Rider App',
        theme: ThemeData(
          fontFamily: 'Brand-regualar',
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: LoginScreen.idScreen,
        routes: 
        {
          RegistrationScreen.idScreen:(context) => RegistrationScreen(),
          LoginScreen.idScreen:(context)=>LoginScreen(),
          MainScreen.idScreen:(context)=>MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}