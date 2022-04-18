import 'dart:convert';

import 'package:cargo_admin/widgets/BrandDivider.dart';
import 'package:cargo_admin/widgets/ProgressDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class NavigationDetails extends StatefulWidget {
  static const String id = 'details';
  const NavigationDetails({Key? key}) : super(key: key);


  @override
  State<NavigationDetails> createState() => _NavigationDetailsState();
}

class _NavigationDetailsState extends State<NavigationDetails> {
  late Query _ref;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    asyncMethod();
  }
  void asyncMethod() async {
    await getData();
  }

  Future<void> getData() async {
    _ref =
        FirebaseDatabase.instance.ref().child('cargos').orderByChild('company');
    setState(() {
      isLoading = false;
    });
  }

  Widget _buildCargoList({Object? data,String? key}) {
    final jsonData = json.decode(json.encode(data));
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                const Text("ID:"),
                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Text(
                    key!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),

            Row(
              children: <Widget>[
                const Text("From Address:"),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    jsonData['from_address'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],

            ),
            const SizedBox(height: 10,),
            Row(
              children: <Widget>[
                const Text("To Address:"),
                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Text(
                    jsonData['to_address'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),

            Row(
              children: <Widget>[
                const Text("Company:"),
                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Text(
                    jsonData['company'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: <Widget>[
                const Text("Driver Name"),
                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Text(
                    jsonData['driver'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: <Widget>[
                const Text("User phone:"),
                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Text(
                    jsonData['user_phone'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(width: 20,),
                GestureDetector(
                    child: Icon(Icons.phone,),
                  onTap: ()async{
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: jsonData['user_phone'],
                    );
                    await launch(launchUri.toString());
                  },
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: <Widget>[
                const Text("Status:"),
                const SizedBox(
                  width: 5,
                ),

                Expanded(
                  child: Text(
                    jsonData['status'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const ProgressDialog(status: "Loading") :SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Navigation details"),
        ),
        body: Container(
          height: double.infinity,
          child: FirebaseAnimatedList(
            query: _ref,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              Object? data = snapshot.value;

              return _buildCargoList(data: data,key: snapshot.key);
            },
          ),
        ),
      ),
    );
  }
}
