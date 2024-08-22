import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Appinfo/app_info.dart';
import '../Const/global_var.dart';
import '../Models/direction_deteils.dart';
import '../locatio Auto Fill/model/add_model.dart';

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar(
          "your Internet is not Available. Check your connection. Try Again.",
          context);
    }
  }

  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  ///Reverse GeoCoding
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    String apiGeoCodingUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error") {
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.placeName = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);

      

    }

    return humanReadableAddress;
  }

  ///Directions API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if (responseFromDirectionsAPI == "error") {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString =responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits =responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];



    detailsModel.durationTextString =responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits =responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];
   
   detailsModel.encodedPoints =responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

  ///Directions API
  /*calculateFareAmount(DirectionDetails directionDetails)
  {
    double distancePerKmAmount = 2.0;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount = 2;

    double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigits! / 100) * distancePerKmAmount;
    double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    double overAllTotalFareAmount = baseFareAmount + totalDistanceTravelFareAmount + totalDurationSpendFareAmount;

    return overAllTotalFareAmount.toStringAsFixed(1);
  }*/

   Future<String> calculateFareAmountFor3Seats(DirectionDetails directionDetails) async {
  
  double distancePerKmAmount = .0;
  double durationPerMinuteAmount = 0;
  double baseFareAmount = 0;
  
  DatabaseReference fareDataRef = FirebaseDatabase.instance.ref().child('fareData').child('Autorickshaw');

  // Fetch the fare data from Firebase
  DataSnapshot snapshot = await fareDataRef.get();

  if (snapshot.exists) {
    // Extract data from the snapshot
    double vehicleFare = double.parse(snapshot.child('vehicle Fare').value.toString());
    double kmFare = double.parse(snapshot.child('kmFare').value.toString().replaceAll('/km', ''));
    double minutesFare = double.parse(snapshot.child('Minutes Fare').value.toString());
    double taxAmount = double.parse(snapshot.child('taxAmount (Gst)').value.toString());
    

    baseFareAmount = vehicleFare;
    distancePerKmAmount = kmFare;
    durationPerMinuteAmount =minutesFare;

     print("baseFareAmount=======333333333333333==============================$baseFareAmount");
     
     print("kmFare===============3333333333333======================$kmFare");
     
     print("vehicleFare====================33333333333333=================$vehicleFare");

    // Assuming the fare calculation is influenced by the number of seats
    double seatFactor = 3; // For 3 seats

    double totalDistanceTravelFareAmount =(directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    
        
    double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    
    

    double overAllTotalFareAmount = baseFareAmount + (totalDistanceTravelFareAmount + totalDurationSpendFareAmount) ;
    

    return overAllTotalFareAmount.toStringAsFixed(1);
  }

  // Return a default value or error message when snapshot does not exist
  return "Fare data not available";
}

 Future<String> calculateFareAmountFor4Seats(DirectionDetails directionDetails) async {
  
  double distancePerKmAmount = .0;
  double durationPerMinuteAmount = 0;
  double baseFareAmount = 0;
  
  DatabaseReference fareDataRef = FirebaseDatabase.instance.ref().child('fareData').child('SUVs');

  // Fetch the fare data from Firebase
  DataSnapshot snapshot = await fareDataRef.get();

  if (snapshot.exists) {
    // Extract data from the snapshot
    double vehicleFare = double.parse(snapshot.child('vehicle Fare').value.toString());
    double kmFare = double.parse(snapshot.child('kmFare').value.toString().replaceAll('/km', ''));
    double minutesFare = double.parse(snapshot.child('Minutes Fare').value.toString());
    double taxAmount = double.parse(snapshot.child('taxAmount (Gst)').value.toString());
    

    baseFareAmount = vehicleFare;
    distancePerKmAmount = kmFare;
    durationPerMinuteAmount =minutesFare;

     print("baseFareAmount=======444444444444444444==============================$baseFareAmount");
     
     print("kmFare===============44444444444444======================$kmFare");
     
     print("vehicleFare==================444444444444=================$vehicleFare");

    // Assuming the fare calculation is influenced by the number of seats
    double seatFactor = 3; // For 3 seats

    double totalDistanceTravelFareAmount =(directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    
        
    double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    
    

    double overAllTotalFareAmount = baseFareAmount + (totalDistanceTravelFareAmount + totalDurationSpendFareAmount) ;
    

    return overAllTotalFareAmount.toStringAsFixed(1);
  }

  // Return a default value or error message when snapshot does not exist
  return "Fare data not available";
}

 Future<String> calculateFareAmountFor7Seats(DirectionDetails directionDetails) async {
  
  double distancePerKmAmount = .0;
  double durationPerMinuteAmount = 0;
  double baseFareAmount = 0;
  
  DatabaseReference fareDataRef = FirebaseDatabase.instance.ref().child('fareData').child('premium');

  // Fetch the fare data from Firebase
  DataSnapshot snapshot = await fareDataRef.get();

  if (snapshot.exists) {
    // Extract data from the snapshot
    double vehicleFare = double.parse(snapshot.child('vehicle Fare').value.toString());
    double kmFare = double.parse(snapshot.child('kmFare').value.toString().replaceAll('/km', ''));
    double minutesFare = double.parse(snapshot.child('Minutes Fare').value.toString());
    double taxAmount = double.parse(snapshot.child('taxAmount (Gst)').value.toString());
    

    baseFareAmount = vehicleFare;
    distancePerKmAmount = kmFare;
    durationPerMinuteAmount =minutesFare;

     print("baseFareAmount=======7777777777777777==============================$baseFareAmount");
     
     print("kmFare===============7777777777777777777======================$kmFare");
     
     print("vehicleFare===========77777777777777777=================$vehicleFare");

    // Assuming the fare calculation is influenced by the number of seats
    double seatFactor = 3; // For 3 seats

    double totalDistanceTravelFareAmount =(directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    
        
    double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    
    

    double overAllTotalFareAmount = baseFareAmount + (totalDistanceTravelFareAmount + totalDurationSpendFareAmount) ;
    

    return overAllTotalFareAmount.toStringAsFixed(1);
  }

  // Return a default value or error message when snapshot does not exist
  return "Fare data not available";
}
}