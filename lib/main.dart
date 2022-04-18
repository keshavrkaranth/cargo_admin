import 'package:cargo_admin/dataprovider/appdata.dart';
import 'package:cargo_admin/screens/adddetails.dart';
import 'package:cargo_admin/screens/home.dart';
import 'package:cargo_admin/screens/loginpage.dart';
import 'package:cargo_admin/screens/phonelogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs',
      appId: '1:514277127247:android:83404ef68d2e034c66663a',
      messagingSenderId: '448618578101',
      projectId: 'cargo-tracking-815a8',
      databaseURL: 'https://cargo-tracking-815a8-default-rtdb.firebaseio.com',
      storageBucket: 'cargo-tracking-815a8.appspot.com',
    ),
  );



  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create:(context) => AppData(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Brand-Regular',
        primarySwatch: Colors.blue,
      ),
      initialRoute:  (FirebaseAuth.instance.currentUser==null) ? LoginPage.id : HomePage.id ,
      routes: {
        HomePage.id :(context) =>  HomePage(),
        AddDetails.id :(context)=> AddDetails(),
        PhoneLogin.id :(context) => const PhoneLogin(),
        LoginPage.id :(context)=> const LoginPage(),
      },
    ),
    );
  }
}
