import 'package:flutter/cupertino.dart';

import '../datamodels/address.dart';

class AppData extends ChangeNotifier{

  late Address pickupAddress;
  late Address destinationAddress;
  void updatePickupAddress(Address pickup){
    pickupAddress  = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination){
    destinationAddress = destination;
    notifyListeners();
  }
}