import 'dart:convert';
import 'dart:math';
import 'package:cargo_admin/screens/home.dart';
import 'package:cargo_admin/screens/navigationdetails.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:cargo_admin/dataprovider/appdata.dart';
import 'package:cargo_admin/widgets/ProgressDialog.dart';
import 'package:cargo_admin/widgets/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../constants.dart';
import '../datamodels/directiondetails.dart';
import '../helpers/helpermethods.dart';

class AddDetails extends StatefulWidget {
  static const String id = 'add';
  AddDetails({Key? key}) : super(key: key);

  @override
  State<AddDetails> createState() => _AddDetailsState();
}

class _AddDetailsState extends State<AddDetails> {
  List<dynamic> companyTypesList = [];

  List<dynamic> driverTypesList = [];

  List<dynamic> drivers = [];
  List<dynamic> tempDrivers = [];
  List<dynamic> phoneNumbers = [];
  String? userName = "user";
  String? token;

  bool loading = true;

  TextEditingController fromController = TextEditingController();

  TextEditingController toController = TextEditingController();
  TextEditingController value = TextEditingController();
  TextEditingController driverId = TextEditingController();
  TextEditingController userPhoneNumber = TextEditingController();
  late DirectionDetails tripDirectionDetails;
  late LatLng pickupLatLng;
  late LatLng dropLatLng;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    adAddressDetails();
    asyncMethod();
    tripDirectionDetails = DirectionDetails(
        distanceText: '0',
        durationText: '0',
        distanceValue: '0',
        durationValue: '0',
        encodedPoints: '0');
  }

  void asyncMethod() async {
    await addDataToList();
  }

  Future<void> addDataToList() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("company");
    await ref.once().then((value) {
      final snapshot = value.snapshot;
      final myData = json.decode(json.encode(snapshot.value));
      for (var i in myData) {
        if (i != null) {
          companyTypesList.add(i);
        }
      }
    });
    DatabaseReference ref1 = FirebaseDatabase.instance.ref("drivers");
    await ref1.once().then((value) {
      final snapshot = value.snapshot;
      final myData = json.decode(json.encode(snapshot.value));
      Map<String, dynamic> data = Map<String, dynamic>.from(myData);
      for (var i in data.values) {
        driverTypesList.add(i);
      }
    });
    print(companyTypesList);
    print(driverTypesList);

    DatabaseReference ref2 = FirebaseDatabase.instance.ref("users");

    await ref2.once().then((value) {
      final snapshot = value.snapshot;
      final myData = json.decode(json.encode(snapshot.value));
      Map<String, dynamic> data = Map<String, dynamic>.from(myData);
      for (var i in data.values) {
        Map<String, dynamic> data1 = Map<String, dynamic>.from(i);
        for (var j in data1.keys) {
          if (j == 'phone') {
            phoneNumbers.add(data1[j]);
          }
        }
      }
    });
    setState(() {
      loading = false;
    });
  }

  void adAddressDetails() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    fromController.text = pickup.placeFormatAddress;
    toController.text = destination.placeFormatAddress;
    setState(() {
      pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
      dropLatLng = LatLng(destination.latitude, destination.longitude);
    });
    var thisDetails = await HelperMethods.getDirectionsDetails(
        pickupLatLng, dropLatLng);
    setState(() {
      tripDirectionDetails = thisDetails!;
    });
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState?.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const ProgressDialog(status: "Loading...")
        : SafeArea(
            child: Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, HomePage.id, (route) => false);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text(
                  "Add details",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Fill Driver Details",
                      style: TextStyle(fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 0, right: 25, top: 25, left: 25),
                      child: TextField(
                        enabled: false,
                        controller: fromController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            labelText: 'From Address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, bottom: 0, top: 25),
                      child: TextField(
                        controller: toController,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            labelText: 'To Address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    SingleChildScrollView(
                      child: FormHelper.dropDownWidgetWithLabel(
                          context, "", "Company", value, companyTypesList,
                          (onChanged) async {
                        setState(() {
                          value.text = onChanged;
                          drivers = driverTypesList
                              .where((element) =>
                                  element['parentId'].toString() ==
                                  onChanged.toString())
                              .toList();
                          driverId.text = "";
                        });
                      }, (onValidate) {}),
                      padding: const EdgeInsets.only(
                          left: 0, top: 5, right: 5, bottom: 0),
                    ),
                    SingleChildScrollView(
                      child: FormHelper.dropDownWidgetWithLabel(
                          context, "", "Select Drivers", driverId, drivers,
                          (onChanged) {
                        setState(() {
                          driverId.text = onChanged.toString();
                        });
                      }, (onValidate) {},
                          optionValue: "fullname", optionLabel: "fullname"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: TextField(
                        controller: userPhoneNumber,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                                borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                            labelText: 'User phone number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: const TextStyle(fontSize: 14),
                      ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(30),
                      child: TaxiOutlineButton(
                        color: Colors.blue,
                        onPressed: () {
                          validateInputs();
                        },
                        title: "Submit",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void validateInputs() {
    if (value.text.isEmpty) {
      showSnackBar("Driving company is required..");
      return;
    }
    if (driverId.text.isEmpty) {
      showSnackBar("Driver is required...");
      return;
    }
    if (userPhoneNumber.text.isEmpty) {
      showSnackBar("Please Enter the user phone number");
      return;
    }
    addDataToFirebase();

  }


  void addDataToFirebase() {

    for (var i in companyTypesList) {
      if (i['id'].toString() == value.text.toString()) {
        setState(() {
          value.text = i['name'];
        });
      }
    }
    String uid = generateRandomString(8);
    Map data = {
      'created_at':DateTime.now().toString(),
      'from_address': fromController.text.toString(),
      'from_lat_lng': {
        'lat':
            pickupLatLng.latitude,
        'lng':
            pickupLatLng.longitude
      },
      "to_address": toController.text.toString(),
      'to_lat_lng': {
        'lat': dropLatLng.latitude,
        'lng': dropLatLng.longitude
      },
      'total_distance':tripDirectionDetails.distanceText.toString(),
      'total_time':tripDirectionDetails.durationText.toString(),
      "company": value.text.toString(),
      "driver": driverId.text.toString(),
      "user_phone": userPhoneNumber.text.toString(),
      "status": "assigned"
    };
    print(data);
    DatabaseReference ref = FirebaseDatabase.instance.ref("cargos/$uid");
    ref.set(data);
    sendSms(userPhoneNumber.text);
    setDriverToken(driverId.text);
    sendFirebaseNotification(token);
    Fluttertoast.showToast(
        msg: "Submitted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.pushNamedAndRemoveUntil(context, NavigationDetails.id, (route) => false);
  }

  Future<void> sendFirebaseNotification(token) async {

    var headers = {
      'Authorization': 'key=AAAAd71ONE8:APA91bEDRP0-_qos2fUpGa1ba_M2UkygXWe4hqxnbshysnta947W4LYVcPI11baDIoubjsr6gwbOj5P75MUtKBfTSGO-aTxqU3Mkq6Y1QRdKLKSR5B1JfQidiewDbbQKj_lTpNWeD0_S',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": token,
      "notification": {
        "body": "A new Parcel arrived..",
        "OrganizationId": "2",
        "content_available": true,
        "priority": "high",
        "subtitle": "Chek it out",
        "Title": "A new Parcel arrived.."
      },
      "data": {
        "priority": "high",
        "content_available": true,
        "ride_id": "-MvMblFOZehJPnprqnif"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }
  Future<void> setDriverToken(name) async {
    Query ref = FirebaseDatabase.instance
        .ref('drivers')
        .orderByChild("fullname")
        .equalTo(name);
    await ref.once().then((value) {
      final snapshot = value.snapshot;
      final myData = json.decode(json.encode(snapshot.value));
      if (myData != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(myData);
        for (var i in data.values) {
          setState(() {
            token = i['token'];
          });
        }
      }
    });
  }
  Future<void> setUserName(number) async {
    Query ref = FirebaseDatabase.instance
        .ref('users')
        .orderByChild("phone")
        .equalTo(number);
    await ref.once().then((value) {
      final snapshot = value.snapshot;
      final myData = json.decode(json.encode(snapshot.value));
      if (myData != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(myData);
        for (var i in data.values) {
          setState(() {
            userName = i['fullname'];
          });
        }
      }
    });
  }

  void sendSms(number) async {
    await setUserName(number);
    twilioFlutter?.sendSMS(
        toNumber: "+91$number",
        messageBody:
            "Hello $userName your package is just assigned to a driver wait till he starts the trip.. to see driver details visit our app");
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join()
        .toUpperCase();
  }
}
