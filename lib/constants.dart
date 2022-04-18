import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cargo_admin/datamodels/user.dart' as user;
import 'package:firebase_database/firebase_database.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import 'datamodels/predections.dart';

String mapKey = 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs';
List<Predictions> destinationAddressLis = [];
User currentFirebaseUser = FirebaseAuth.instance.currentUser!;

user.User? currentUser;


TwilioFlutter? twilioFlutter;
