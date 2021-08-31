import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_uber/AllScreens/searchScreen.dart';
import 'package:my_uber/AllWidgets/divider.dart';
import 'package:my_uber/AllWidgets/progressDialog.dart';
import 'package:my_uber/Assistants/assistantMethods.dart';
import 'package:my_uber/DataHandler/appData.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController dropoffTextEditingController = TextEditingController();
  TextEditingController pRnameTextEditingController = TextEditingController();
  TextEditingController cAnameTextEditingController = TextEditingController();
  TextEditingController iDnameTextEditingController = TextEditingController();
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  
  String? searchAddr;
  

  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  List<LatLng>plineCoordinate = [];
  Set<Polyline> polylineSet={};
  
  late Position currentPosition;
  var geolocator = Geolocator();
  double bottomPaddingOfMap=0;


   Set<Marker> markersSet = {}; 
   Set<Circle> circlesSet = {};



  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    // ignore: non_constant_identifier_names
    LatLng latLngPosition=LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        String address = await AssistantMethods.searchCoordinateAddress(position, context);
        print("this is your address:: "+ address);

  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text("Nervar Logistics"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png"),
                      SizedBox(
                        width: 14.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Name",
                            style: TextStyle(fontSize: 15.0),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text("Visit Profile")
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Dividerwidget(),
              SizedBox(
                height: 12.0,
              ),

              //drawer body controllers

              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "about",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet ,
            markers: markersSet,
            circles: circlesSet,

            onMapCreated: (GoogleMapController controller) {

              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });


              locatePosition();
            },
          ),

          //hambugger button for dinner
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                scaffoldkey.currentState!.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.white,
                  radius: 20.0,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16.0,
                    color: Colors.black,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 6.0,
                    ),
                    Text(
                      "Hi there",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      "Where are you sending your parcel to?",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: ()async {
                      var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen()));

                      if (res == "obtainDirection"){
                        await getPlaceDirection();
                      }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6.0,
                              color: Colors.black54,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text("Set Drop off Location"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Provider.of<AppData>(context).pickUpLocation != null
                              ? Provider.of<AppData>(context).pickUpLocation!.placeName ??""
                              : "Add home"
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              "Your Current Address",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Dividerwidget(),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.work,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add work"),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              "Your Office Address",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Future<void> getPlaceDirection() async
{
  var initialPos = Provider.of<AppData>(context, listen:false ).pickUpLocation;
  var finalPos = Provider.of<AppData>(context, listen:false ).dropOffLocation;

  var pickUpLatLng = LatLng(initialPos!.latitude!,initialPos.longitude!);
  var dropOffLatLng = LatLng(finalPos!.latitude!,finalPos.longitude!);

  showDialog(context: context,
   builder: (BuildContext context)=> ProgressDialog(message: "setting Drop off, Please wait...",)    
   );

   var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);

   Navigator.pop(context);

   print("This is encoded points::  ");
   print(details!.encodedPoints);

   PolylinePoints polylinePoints = PolylinePoints();
   List<PointLatLng> decodedPolylinePointsResult = polylinePoints.decodePolyline(details.encodedPoints.toString());

   plineCoordinate.clear();

   if(decodedPolylinePointsResult.isNotEmpty){
     decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
       plineCoordinate.add( LatLng(pointLatLng.latitude, pointLatLng.longitude));
     });
   }

  polylineSet.clear();

setState(() {
  Polyline polyline = Polyline(
    color: Colors.pink,
    polylineId: PolylineId("polylineID"),
    jointType: JointType.round,
    points: plineCoordinate,
    width: 5,
    startCap: Cap.roundCap,
    endCap: Cap.roundCap,
    geodesic: true,
    );

    polylineSet.add(polyline);
});

LatLngBounds latLngBounds;

if(pickUpLatLng.latitude>dropOffLatLng.latitude && pickUpLatLng.longitude>dropOffLatLng.longitude){

  latLngBounds = LatLngBounds(southwest: dropOffLatLng,northeast: pickUpLatLng);
}
 else if(pickUpLatLng.longitude>dropOffLatLng.longitude ){

   latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude,dropOffLatLng.longitude),northeast:LatLng(dropOffLatLng.latitude,pickUpLatLng.longitude));

}

  else if(pickUpLatLng.latitude>dropOffLatLng.latitude ){

   latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude,pickUpLatLng.longitude),northeast:LatLng(pickUpLatLng.latitude,dropOffLatLng.longitude));

}
else{
  latLngBounds = LatLngBounds(southwest: pickUpLatLng,northeast: dropOffLatLng);
}
newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

Marker pickUpLocMarker= Marker(
  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My Location"),
  position: pickUpLatLng,
  markerId: MarkerId("pickUpId")

);
Marker dropOffLocMarker= Marker(
  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
  infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Dropoff Location"),
  position: dropOffLatLng,
  markerId: MarkerId("dropOffId")

);
setState(() {
  markersSet.add(pickUpLocMarker);
  markersSet.add(dropOffLocMarker);
});

Circle pickUpLocCircle = Circle(
  fillColor: Colors.blueAccent,
  center: pickUpLatLng,
  radius: 12,
  strokeWidth: 4,
  strokeColor: Colors.greenAccent,
  circleId: CircleId("pickUpId")
);

Circle dropOffLocCircle = Circle(
  fillColor: Colors.purpleAccent,
  center: dropOffLatLng,
  radius: 12,
  strokeWidth: 4,
  strokeColor: Colors.orangeAccent,
  circleId: CircleId("dropOffId")
);

setState(() {
  circlesSet.add(pickUpLocCircle);
  circlesSet.add(dropOffLocCircle);
});

}
}
