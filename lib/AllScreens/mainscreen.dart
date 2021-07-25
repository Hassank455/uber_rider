import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/AllScreens/searchScreen.dart';
import 'package:uber_rider_app/AllWidgets/divider.dart';
import 'package:uber_rider_app/AllWidgets/progressDialog.dart';
import 'package:uber_rider_app/Assistants/assistantMethode.dart';
import 'package:uber_rider_app/DataHandler/appData.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double riderDetailsContainerHeight = 0;
  double searchContainerHeight = 300.0;

  void displayRiderDetailsContainer()async{
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      riderDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethod.searchCoordinateAddress(position, context);
    print("This is your address :: " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Main Screen'),
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
                      Image.asset(
                        "assets/images/user_icon.png",
                        height: 65.0,
                        width: 65.0,
                      ),
                      SizedBox(width: 16.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hassan kamal',
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Brand Bold"),
                          ),
                          SizedBox(height: 6.0),
                          Text('Visit Profile'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              DividerWidget(),
              SizedBox(height: 12.0),
              //Drawer Body Controller
              ListTile(
                leading: Icon(Icons.history),
                title: Text('History', style: TextStyle(fontSize: 15.0)),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Visit Profile', style: TextStyle(fontSize: 15.0)),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About', style: TextStyle(fontSize: 15.0)),
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
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
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

          //HamburgerButton for Drawer
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState!.openDrawer();
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
                      offset: Offset(0.4, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
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
              duration: new Duration(milliseconds: 160),
              curve: Curves.bounceIn,
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
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text('Hi there', style: TextStyle(fontSize: 12.0)),
                      Text('Where to?',
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: "Brand Bold")),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(),
                              ));

                          if (res == "obtainDirection") {
                            displayRiderDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent),
                                SizedBox(width: 10.0),
                                Text('Search Drop off',
                                    style: TextStyle(fontSize: 12.0)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.grey),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Provider.of<AppData>(context).pickUpLocation !=
                                      null
                                  ? Provider.of<AppData>(context)
                                      .pickUpLocation!
                                      .placeName!
                                  : 'Add Home'),
                              SizedBox(height: 4.0),
                              Text(
                                'Your living Home address',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10.0),
                      DividerWidget(),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey),
                          SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              SizedBox(height: 4.0),
                              Text(
                                'Your Office address',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12.0),
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

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 160),
              curve: Curves.bounceIn,
              child: Container(
                height: riderDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/taxi.png",
                                height: 70.0,
                                width: 80.0,
                              ),
                              SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Car",
                                    style: TextStyle(
                                        fontSize: 18.0, fontFamily: "Brand Bold"),
                                  ),
                                  Text(
                                    "10Km",
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 18.0,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 16.0),
                            Text("Cash"),
                            SizedBox(width: 6.0),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: RaisedButton(
                        onPressed: () {
                          print('clicked');
                        },
                            color: Theme.of(context).accentColor,
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
                                  Icon(FontAwesomeIcons.taxi, color: Colors.white, size: 26.0),
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
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latiude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latiude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (context) => ProgressDialog(message: 'Please wait...'));

    var details = await AssistantMethod.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print("this is Encoded points ::");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints!);

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
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

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker droopOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatLng,
      markerId: MarkerId("droopOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(droopOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("droopOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
