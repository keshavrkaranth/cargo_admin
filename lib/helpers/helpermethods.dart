import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../datamodels/address.dart';
import '../datamodels/directiondetails.dart';
import '../dataprovider/appdata.dart';
import 'requesthelper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cargo_admin/datamodels/user.dart' as user;
class HelperMethods {

  static void getCurrentUserInfo() async{
    currentFirebaseUser = FirebaseAuth.instance.currentUser!;
    print(currentFirebaseUser);
    String userId = currentFirebaseUser.uid;
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('admin/$userId');
    userRef.once().then((event) {
      final dataSnapshot = event.snapshot;
      if(dataSnapshot.value !=null){
        currentUser = user.User.fromSnapshot(dataSnapshot);
      }
    }
    );
  }


  static Future<String> findCordinateAddress(Position position, context) async {
    String placeAddress = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';

    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = Address(
          longitude: position.longitude,
          latitude: position.latitude,
          placeName: placeAddress,
          placeId: '1',
          placeFormatAddress: placeAddress);

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> getDirectionsDetails(LatLng start,LatLng end) async{
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if(response == 'failed'){
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails(
        durationText: response['routes'][0]['legs'][0]['duration']['text'],
        durationValue: response['routes'][0]['legs'][0]['duration']['value'].toString(),
        distanceText: response['routes'][0]['legs'][0]['distance']['text'],
        distanceValue: response['routes'][0]['legs'][0]['distance']['value'].toString(),
        encodedPoints: response['routes'][0]['overview_polyline']['points'].toString()
    );
    return directionDetails;
  }

  static int estimateFares(DirectionDetails details){
    double baseFare = 3;
    double distanceFare = (int.parse(details.distanceValue)/1000)*0.3;
    double timeFare = (int.parse(details.distanceValue)/60)*0.2;

    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();

  }


  static double generateRandomNumber(int max){
    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);
    return randInt.toDouble();
  }
}
