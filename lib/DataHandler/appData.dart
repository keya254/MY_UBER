import 'package:flutter/cupertino.dart';
import 'package:my_uber/Models/address.dart';

class AppData extends ChangeNotifier{

  Address? pickUpLocation, dropOffLocation, receiversName, receiversPhone;

  void updatePickUpLocationAddress(Address pickUpAddress){
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

   void updateDropOffLocationAddress(Address dropOffAddress){
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }


}