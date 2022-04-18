import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

class User{
   String? fullName;
   String? email;
   String? phone;
   String? id;
  User({
     this.email,
     this.fullName,
     this.id,
     this.phone
  });
  User.fromSnapshot(DataSnapshot snapshot){
    final fireBaseValue = snapshot.value;
    final mapData = json.decode(json.encode(fireBaseValue));
    id = snapshot.key!;
    phone = mapData['phone']!.toString();
    email=mapData['email']!;
    fullName = mapData['fullname']!;
  }

}