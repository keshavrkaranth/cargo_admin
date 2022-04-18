import 'dart:async';
import 'package:cargo_admin/screens/adddetails.dart';
import 'package:cargo_admin/screens/navigationdetails.dart';
import 'package:cargo_admin/screens/phonelogin.dart';
import 'package:cargo_admin/screens/searchpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import '../brandcolors.dart';
import '../constants.dart';
import '../datamodels/directiondetails.dart';
import '../dataprovider/appdata.dart';
import '../helpers/helpermethods.dart';

import 'dart:io';

import '../styles/styles.dart';
import '../widgets/BrandDivider.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/TaxiButton.dart';

class HomePage extends StatefulWidget {
  static const String id = 'main';
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool isLoading = false;
  final Completer<GoogleMapController> _controller = Completer();
  double mapBottomPadding = 0;
  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double rideDetailsHeight = 0; //(Platform.isAndroid) ? 235 : 200;
  double requestingSheetHeight = 0; //(Platform.isAndroid) ? 195 : 220;

  late DatabaseReference rideRef;

  late GoogleMapController mapController;
  List<LatLng> polyLineCoordinates = [];
  final Set<Polyline> polyLines = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  late DirectionDetails tripDirectionDetails;
  bool drawerCanOpen = true;
  bool nearByDriversKeysLoaded = false;
  late CameraPosition cp;

  var geoLocator = Geolocator();
  late Position currentPosition;

  late BitmapDescriptor nearbyIcon;

  Future<void> setupPositionLocator() async {
    setState(() {
      isLoading = true;
    });
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    await HelperMethods.findCordinateAddress(position, context);
    setState(() {
      currentPosition = position;
    });
    LatLng pos = LatLng(position.latitude, position.longitude);
    cp = CameraPosition(target: pos, zoom: 14);
    setState(() {
      isLoading = false;
    });

  }

  void showDetailsSheet() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      rideDetailsHeight = (Platform.isAndroid) ? 235 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet() {
    setState(() {
      rideDetailsHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;
      drawerCanOpen = true;
    });
    createRideRequest();
  }

  void createMarker() {
    ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context, size: const Size(2, 2));
    BitmapDescriptor.fromAssetImage(imageConfiguration,
            (Platform.isIOS) ? 'images/car_ios.png' : 'images/car_android.png')
        .then((icon) {
      nearbyIcon = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeTwilio();

    setupPositionLocator();
    tripDirectionDetails = DirectionDetails(
        distanceText: '0',
        durationText: '0',
        distanceValue: '0',
        durationValue: '0',
        encodedPoints: '0');
    HelperMethods.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const ProgressDialog(status: 'Loading...')
        : Scaffold(
            key: scaffoldKey,
            drawer: Container(
              width: 250,
              color: Colors.white,
              // navigation drawer
              child: Drawer(
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      height: 160,
                      child: DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'images/user_icon.png',
                              height: 60,
                              width: 60,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  <Widget>[
                                Text(
                                  currentUser!.fullName!,
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: 'Brand-Bold'),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text('View Profile'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const BrandDivider(),
                    const SizedBox(
                      height: 10,
                    ),
                     ListTile(
                      leading: const Icon(Icons.navigation),
                      title: const Text(
                        'Add a navigation',
                        style: kDrawerItemStyle,
                      ),
                       onTap: (){
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) => HomePage(),
                           ),
                         );
                       },
                    ),
                     ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text(
                        'Navigation History',
                        style: kDrawerItemStyle,
                      ),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavigationDetails(),
                          ),
                        );
                      },

                    ),
                    const ListTile(
                      leading: Icon(Icons.contact_support),
                      title: Text(
                        'Support',
                        style: kDrawerItemStyle,
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text(
                        'About',
                        style: kDrawerItemStyle,
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PhoneLogin()));
                      },
                      leading:  const Icon(Icons.logout),
                      title: const Text(
                        'Logout',
                        style: kDrawerItemStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  padding: EdgeInsets.only(bottom: mapBottomPadding, top: 40),
                  // initialCameraPosition: _kGooglePlex,
                  initialCameraPosition: cp,
                  compassEnabled: true,
                  zoomGesturesEnabled: true,
                  mapType: MapType.satellite,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: polyLines,
                  markers: markers,
                  circles: circles,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _controller.complete(controller);

                    setState(() {
                      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
                    });
                  },
                ),
                // menu button
                Positioned(
                  top: 44,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (drawerCanOpen) {
                        scaffoldKey.currentState?.openDrawer();
                      } else {
                        resetApp();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(
                                  0.7,
                                  0.7,
                                )),
                          ]),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                // search sheet
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSize(
                    vsync: this,
                    duration: const Duration(microseconds: 150),
                    curve: Curves.easeIn,
                    child: Container(
                      height: searchSheetHeight,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Nice to see you!',
                              style: TextStyle(fontSize: 10),
                            ),
                            const Text(
                              'Where are you going?',
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'Brand-Bold'),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var response = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SearchPage()));
                                if (response == 'getDirection') {
                                  showDetailsSheet();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5.0,
                                        spreadRadius: 0.5,
                                        offset: Offset(0.7, 0.7),
                                      )
                                    ]),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const <Widget>[
                                      Icon(
                                        Icons.search,
                                        color: Colors.blueAccent,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Search destination'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 22,
                            ),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.home,
                                  color: BrandColors.colorDimText,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .75,
                                        child: Text(
                                          (Provider.of<AppData>(context)
                                                      .pickupAddress !=
                                                  null)
                                              ? Provider.of<AppData>(context,
                                                      listen: false)
                                                  .pickupAddress
                                                  .placeName
                                              : "Add Home",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        )),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    const Text(
                                      "Your residential address",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: BrandColors.colorDimText),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const BrandDivider(),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.work,
                                  color: BrandColors.colorDimText,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Text('Add Work'),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      "Your office address",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: BrandColors.colorDimText),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ride details
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSize(
                    vsync: this,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7))
                        ],
                      ),
                      height: rideDetailsHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 80,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: TaxiOutlineButton(
                                title: 'PROCEED',
                                color: Colors.green,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddDetails()));
                                  showRequestingSheet();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  void initializeTwilio()async{
    twilioFlutter =  TwilioFlutter(accountSid: "ACe5540840f09d2c2fc9cabaa750c8d0e3", authToken: "a588aba09e9ca9aa392d739dedfbaeba", twilioNumber: '(938) 300-4223');
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            const ProgressDialog(status: 'Please wait...'),
        barrierDismissible: false);
    var thisDetails = await HelperMethods.getDirectionsDetails(
        pickupLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetails = thisDetails!;
    });

    Navigator.pop(context);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails!.encodedPoints);
    polyLineCoordinates.clear();
    if (results.isNotEmpty) {
      for (var point in results) {
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    polyLines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polyid'),
        color: const Color.fromARGB(255, 95, 109, 237),
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.latitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));

    Marker pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My location'),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('drop'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );
    setState(() {
      markers.add(pickupMarker);
      markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: const CircleId('pickup'),
        strokeColor: BrandColors.colorGreen,
        strokeWidth: 3,
        radius: 12,
        center: pickupLatLng,
        fillColor: BrandColors.colorGreen);

    Circle destinationCircle = Circle(
        circleId: const CircleId('destination'),
        strokeColor: BrandColors.colorAccentPurple,
        strokeWidth: 3,
        radius: 12,
        center: destinationLatLng,
        fillColor: BrandColors.colorAccentPurple);

    setState(() {
      circles.add(pickupCircle);
      circles.add(destinationCircle);
    });
  }




  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUser?.fullName,
      'rider_phone': currentUser?.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'pickup': pickupMap,
      'destination': destinationMap,
      'payment_method': 'card',
      'driver_id': 'waiting..'
    };
    rideRef.set(rideMap);
  }

  void cancelRequest() {
    rideRef.remove();
  }

  resetApp() {
    setState(() {
      polyLineCoordinates.clear();
      polyLines.clear();
      markers.clear();
      circles.clear();
      rideDetailsHeight = 0;
      requestingSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;
    });
    setupPositionLocator();
  }
}
