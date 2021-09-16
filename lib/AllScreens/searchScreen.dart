import 'package:flutter/material.dart';
import 'package:my_uber/AllWidgets/divider.dart';
import 'package:my_uber/AllWidgets/progressDialog.dart';
import 'package:my_uber/Assistants/requestAssistant.dart';
import 'package:my_uber/DataHandler/appData.dart';
import 'package:my_uber/Models/address.dart';
import 'package:my_uber/Models/placePrediction.dart';
import 'package:my_uber/secrets.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
   TextEditingController ?rNameTextEditingController = TextEditingController();
  TextEditingController ?rPhoneTextEditingController = TextEditingController();
  
  List<PlacePredictions> placepredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation?.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 190.0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 5.0,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back)),
                      Center(
                        child: Text(
                          "Set Drop Off",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 20.0,
                        width: 20.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadiusDirectional.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                hintText: "PickUp Location",
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                  right: 11.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
               
                   SizedBox(
                    height: 5.0,
                  ),

    
                  Row(
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 20.0,
                        width: 20.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadiusDirectional.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (val) {
                                findPlace(val);
                              },
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Drop Off",
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                  right: 11.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                   SizedBox(
                    height: 5.0,
                  ),

                ],
              ),
            ),
          ),

         
               SizedBox(
                  height: 1.0,),
               
          
          (placepredictionList.length > 0)
              ? Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                      child: ListView.separated(
                        padding: EdgeInsetsDirectional.all(0.0),
                        itemBuilder: (context, index) {
                          return PredictionTile(
                            placePredictions: placepredictionList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            Dividerwidget(),
                        itemCount: placepredictionList.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                      ),
                    ),
                ),
              )
              : Container(),

          //tile for predictions
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234&components=country:ke";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == "failed") {
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          placepredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions? placePredictions;

  PredictionTile({Key? key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceAddressDetails(placePredictions!.placeId.toString(), context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //guessed this ones though iko na issues
                      Text(placePredictions!.mainText.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0)),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        placePredictions!.secondaryText.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "setting Drop off, please wait...",
            ));
    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    Navigator.pop(context);

    if (res == "failed") {
      return;
    }

    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);


      print("This is drop off location:: ");
      print(address.placeName);

      Navigator.pop(context, "obtainDirection");
    }
  }
}
