import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../brandcolors.dart';
import '../constants.dart';
import '../datamodels/predections.dart';
import '../dataprovider/appdata.dart';
import '../helpers/requesthelper.dart';
import '../widgets/BrandDivider.dart';
import '../widgets/PredictionTile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();
  var focusPickup = FocusNode();
  var focusDestination = FocusNode();

  bool focused = false;
  List<Predictions> destinationAddressLis = [];

  void setFocus(){
    if(!focused){
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  void searchPlace(String placeName) async{
    if(placeName.length>1){
      String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251';
      var response = await RequestHelper.getRequest(url);
      if(response == 'failed'){
        return;
      }
      if(response['status']=='OK'){
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List).map((e) => Predictions.fromJson(e)).toList();
        setState(() {
          destinationAddressLis = thisList;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    String address = Provider.of<AppData>(context).pickupAddress.placeName;
    pickupController.text = address;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 210,
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, top: 48, right: 24, bottom: 20),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 5,
                    ),
                    Stack(children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back)),
                      const Center(
                        child: Text(
                          'Set destination',
                          style:
                          TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                        ),
                      )
                    ]),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'images/pickicon.png',
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: BrandColors.colorLightGrayFair,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: TextField(
                                  controller: pickupController,
                                  focusNode: focusPickup,
                                  onChanged: (value){
                                    searchPlace(value);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Pickup Location',
                                    fillColor: BrandColors.colorLightGray,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                    EdgeInsets.only(left: 10, top: 8, bottom: 8),
                                  ),
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'images/desticon.png',
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: BrandColors.colorLightGrayFair,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: TextField(
                                  controller: destinationController,
                                  focusNode: focusDestination,
                                  onChanged: (value){
                                    searchPlace(value);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Where to.?',
                                    fillColor: BrandColors.colorLightGray,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                    EdgeInsets.only(left: 10, top: 8, bottom: 8),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (destinationAddressLis.isNotEmpty) ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context,index){
                    return PredictionTile(prediction: destinationAddressLis[index]);
                  },
                  separatorBuilder: (BuildContext context,int index) => const BrandDivider(),
                  itemCount: destinationAddressLis.length,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                ),
              ) ,
            ): Container(),
          ],
        ),
      ),
    );
  }
}


