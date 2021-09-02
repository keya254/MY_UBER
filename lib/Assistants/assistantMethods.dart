import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_uber/Assistants/requestAssistant.dart';
import 'package:my_uber/DataHandler/appData.dart';
import 'package:my_uber/Models/address.dart';
import 'package:my_uber/Models/directDetails.dart';
import 'package:provider/provider.dart';
import '../secrets.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position,context ) async 
  {
    String placeAddress = "";
    String st1,st2,st3,st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    
    var response = await RequestAssistant.getRequest(url);

    if (response!= "failed")
    {
     // placeAddress = response["results"][0]["formatted_address"];
     st1 = response["results"][0]["address_components"][0]["long_name"];
     st2 = response["results"][0]["address_components"][1]["long_name"];
     st3 = response["results"][0]["address_components"][4]["long_name"];
     st4 = response["results"][0]["address_components"][5]["long_name"];

     placeAddress = st1 + " ," + st2 + " ," + st3 + " ," + st4;

      Address userPickUpAddress = new Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName  = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {

    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == "failed"){
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints= res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText= res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue= res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText= res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue= res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails){

    //in terms of usd
    double timeTravelledFare = (directionDetails.durationValue! / 60)* 0.20;
    double distanceTravelledFare = (directionDetails.distanceValue! / 1000)* 0.20;
    double totalFareAmount = timeTravelledFare + distanceTravelledFare;


    //1$ = 100Kes
    double totalLocalAmount = totalFareAmount * 100;

    return totalLocalAmount.truncate();
  }
}
