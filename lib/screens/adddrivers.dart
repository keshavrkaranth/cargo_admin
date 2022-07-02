import 'dart:convert';

import 'package:cargo_admin/widgets/ProgressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../widgets/TaxiButton.dart';

class AddDriver extends StatefulWidget {
  const AddDriver({Key? key}) : super(key: key);

  @override
  State<AddDriver> createState() => _AddDriverState();
}

class _AddDriverState extends State<AddDriver> {
  List<dynamic> companyTypesList = [];
  bool loading = false;
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
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addDataToList();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController value = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController userPhone = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();

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
                title: const Text(
                  "Add Driver details",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    const Center(
                      child: Text(
                        "Fill Driver Details",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SingleChildScrollView(
                      child: FormHelper.dropDownWidgetWithLabel(
                          context, "", "Company", value, companyTypesList,
                          (onChanged) async {
                        setState(() {
                          value.text = onChanged;
                        });
                      }, (onValidate) {}),
                      padding: const EdgeInsets.only(
                          left: 0, top: 5, right: 5, bottom: 0),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: TextField(
                        controller: userName,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            labelText: 'Driver name',
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
                          left: 30, right: 30, top: 5, bottom: 10),
                      child: TextField(
                        controller: userPhone,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            labelText: 'Driver phone',
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
                          left: 30, right: 30, top: 10, bottom: 10),
                      child: TextField(
                        controller: userEmail,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            labelText: 'Driver email',
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
                          left: 30, right: 30, top: 10, bottom: 10),
                      child: TextField(
                        controller: userPassword,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.teal),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            labelText: 'Password',
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
                          print("Hello");
                          print("checkk${value.text}");
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

  Future<void> validateInputs()  async {
    if (userName.text.isEmpty) {
      showSnackBar("Driver name is  required..");
      return;
    }
    if (userPhone.text.isEmpty) {
      showSnackBar("Driver phone is  required..");
      return;
    }
    if (userEmail.text.isEmpty) {
      showSnackBar("Driver email is  required..");
      return;
    }
    if (userPassword.text.isEmpty) {
      showSnackBar("Driver password is  required..");
      return;
    }
    var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmail.text.toString(),
        password: userPassword.text.toString());

    DatabaseReference ref =
        FirebaseDatabase.instance.ref('drivers').child(result.user!.uid);

    Map data = {
      "email": userEmail.text.toString(),
      "fullname": userName.text.toString(),
      "phone": userPhone.text.toString(),
      "parentId": 1
    };
    ref.set(data);
    Fluttertoast.showToast(msg: "Driver added to DB");
  }
}
