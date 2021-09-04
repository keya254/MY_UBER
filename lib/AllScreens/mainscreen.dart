import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_uber/AllScreens/searchScreen.dart';
import 'package:my_uber/AllWidgets/divider.dart';
import 'package:my_uber/AllWidgets/progressDialog.dart';
import 'package:my_uber/Assistants/assistantMethods.dart';
import 'package:my_uber/DataHandler/appData.dart';
import 'package:my_uber/Models/directDetails.dart';
import 'package:my_uber/secrets.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController dropoffTextEditingController = TextEditingController();
  TextEditingController ?rNameTextEditingController = TextEditingController();
  TextEditingController ?rPhoneTextEditingController = TextEditingController();
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  String? searchAddr;

  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetails;

  List<LatLng> plineCoordinate = [];
  Set<Polyline> polylineSet = {};

  late Position currentPosition;
  var geolocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;

  bool drawerOpen = true;

  DatabaseReference? rideRequestRef;

  @override
  void initState(){
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest(){

    rideRequestRef = FirebaseDatabase.instance.reference().child("Ride Requests");

    var pickup = Provider.of<AppData>(context,listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context,listen: false).dropOffLocation;


    Map pickUpLocMap = {

      "latitude": pickup?.latitude.toString(),
      "longitude": pickup?.longitude.toString(),

    };
     Map dropOffLocMap = {

      "latitude": dropOff?.latitude.toString(),
      "longitude": dropOff?.longitude.toString(),
      

    };

    Map rideInfoMap = {

      "driver_id":"waiting",
      "payment_method":"cash",
      "payment": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo?.name,
      "rider_phone": userCurrentInfo?.phone,
      "pickup_address":pickup?.placeName,
      "dropoff_address":dropOff?.placeName,
     "rName":rNameTextEditingController!.text,
      "rPhone":rPhoneTextEditingController!.text,
    };

    rideRequestRef?.set(rideInfoMap);
  }

  void cancelRideRequest(){
      rideRequestRef?.remove();

  }


  void displayRequestRideContainer(){
    setState(() {
      requestRideContainerHeight = 350.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;

    });

    saveRideRequest();
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      plineCoordinate.cast();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 360.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    // ignore: non_constant_identifier_names
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("this is your address:: " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 55.0,
      fontFamily: 'Signatra',
    );

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
            polylines: polylineSet,
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
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldkey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
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
                    (drawerOpen) ? Icons.menu : Icons.close,
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
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
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
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));

                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
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
                      SingleChildScrollView(
                        child: Row(
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
                                  Provider.of<AppData>(context)
                                            .pickUpLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                            .pickUpLocation!
                                            .placeName ??
                                        ""
                                    : "Add home",
                                    overflow:TextOverflow.fade ,
                                     
                                    
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
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
             

                          
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:16.0 ),
                  child: Column(
                    children: [
                       Icon(Icons.bolt, size: 28.0,),
                              SizedBox(
                                width: 16.0,
                              ),
                      TextField(
                        controller: rNameTextEditingController,
                        keyboardType: TextInputType.text,
                         decoration: InputDecoration(
                                hintText: "Receivers Name",
                                fillColor: Colors.tealAccent[100],
                                filled: true,
                         ),

                      ),
                       TextField(
                        controller: rPhoneTextEditingController,
                        keyboardType: TextInputType.phone,
                         decoration: InputDecoration(
                                hintText: "Receivers Phone",
                                fillColor: Colors.tealAccent[100],
                                filled: true,
                         ),

                      ),
                      
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/taxi.png",
                                height: 70.0,
                                width: 80.0,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "car",
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  Text(
                                    ((tripDirectionDetails != null)
                                            ? tripDirectionDetails!.distanceText
                                            : '')
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails != null)
                                    ? '\KES ${AssistantMethods.calculateFares(tripDirectionDetails!)}'
                                    : ''),
                                style: TextStyle(fontFamily: "Brand-semibold"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 18.0,
                              color: Colors.black54,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Text("Cash"),
                            SizedBox(
                              width: 6.0,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                       SizedBox(
                        height: 10.0,
                      ),
                   
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            displayRequestRideContainer();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Request",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 26.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //another one
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Requesting a Ride....',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Please wait.....',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Finding a Driver.....',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        repeatForever: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                  SizedBox(height: 22.0,),

                  GestureDetector(
                    onTap: (){
                      cancelRideRequest();
                      resetApp();
                    },
                    child: Container(
                      height:60.0,
                      width: 60.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26.0),
                        border: Border.all(width: 2.0,color: Colors.grey,),
                      ),
                      child: Icon(Icons.close, size: 26.0,),
                      
                      ),
                  ),
                    SizedBox(height: 10.0,),
                    Container(
                      width: double.infinity,
                      child: Text("Cancel Ride", textAlign:TextAlign.center,style: TextStyle(fontSize: 22.0,),),
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

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "setting Drop off, Please wait...",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details!;
    });

    Navigator.pop(context);

    print("This is encoded points::  ");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints.toString());

    plineCoordinate.clear();

    if (decodedPolylinePointsResult.isNotEmpty) {
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        plineCoordinate
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
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

    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: "My Location"),
        position: pickUpLatLng,
        markerId: MarkerId("pickUpId"));
    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "Dropoff Location"),
        position: dropOffLatLng,
        markerId: MarkerId("dropOffId"));
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
        circleId: CircleId("pickUpId"));

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.purpleAccent,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.orangeAccent,
        circleId: CircleId("dropOffId"));

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
