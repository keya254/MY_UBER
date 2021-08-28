import 'package:flutter/cupertino.dart';
import 'package:my_uber/Models/address.dart';

class AppData extends ChangeNotifier{
    Address ?pickUpLocation;

  void updatePickUpLocationAddress(Address pickUpAddress){

    pickUpLocation = pickUpAddress;
    notifyListeners();

  
  }

}