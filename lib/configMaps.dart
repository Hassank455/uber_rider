import 'package:firebase_auth/firebase_auth.dart';

import 'Models/allUsers.dart';

String mapKey = "AIzaSyBU7G7vmeJ2MKnLqDLHj9ATpAupSDRpb0o";

User? firebaseUser;

Users? userCurrentInfo;

int driverRequestTimeOut = 40;
String statusRide = "";
String rideStatus = "Driver is Coming";
String carDetailsDriver = "";
String driverName = "";
String driverPhone = "";

String serverToken = "key=AAAAFIwg5hw:APA91bFyrWGcnY5DBD3F1XcJnZvf8eUgugB2AAhwQivDJKG9EMJPp0VBI2n5LZ-y1Lk03a-qEANRm_0u0ZbfecF1L07hlyikEC3DH0R6ho_fiOpXh9PtJsAmP-QNNwiceWTHDzSxD81H";