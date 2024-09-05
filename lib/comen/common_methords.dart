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
  double distancePerKmAmount = 0.0;
  double durationPerMinuteAmount = 0;
  double baseFareAmount = 0;
  double totalTaxAmount = 0;
  double radiusValue = 0; // Variable to store radius data

  // Get reference to fareData
  DatabaseReference fareDataRef = FirebaseDatabase.instance.ref().child('fareData').child('Autorickshaw');
  // Get reference to radiusData
  DatabaseReference radiusDataRef = FirebaseDatabase.instance.ref().child('radiusData').child("Autorickshaw");

  // Fetch the fare data from Firebase
  DataSnapshot fareSnapshot = await fareDataRef.get();
  // Fetch the radius data from Firebase
  DataSnapshot radiusSnapshot = await radiusDataRef.get();

  if (fareSnapshot.exists) {
    // Extract data from the fareSnapshot
    double vehicleFare = double.parse(fareSnapshot.child('vehicle Fare').value.toString());
    double kmFare = double.parse(fareSnapshot.child('kmFare').value.toString().replaceAll('/km', ''));
    double minutesFare = double.parse(fareSnapshot.child('Minutes Fare').value.toString());
    double taxAmount = double.parse(fareSnapshot.child('taxAmount (Gst)').value.toString());

    baseFareAmount = vehicleFare;
    distancePerKmAmount = kmFare;
    durationPerMinuteAmount = minutesFare;
    totalTaxAmount = taxAmount;
    
  } else {
    return "Fare data not available";
  }

// Variable to hold the radius value

double radiusInMeters; // Declare radiusInMeters outside the if-else block

if (radiusSnapshot.exists) {
  // Extract data from the radiusSnapshot
  radiusValue = double.parse(radiusSnapshot.child('radius').value.toString());

  // Convert radiusValue from kilometers to meters
  radiusInMeters = radiusValue * 1000;

} else {
  // Handle case where radius data is not available
  radiusValue = 0; // Default value or handle as needed

  // Convert radiusValue from kilometers to meters (will still be 0)
  radiusInMeters = radiusValue * 1000;

}

// Calculate fare based on directionDetails and radiusAmount
double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;

// Adjust the fare amount based on radiusInMeters if it's greater than 0
if (radiusInMeters < directionDetails.distanceValueDigits!) {
  totalDistanceTravelFareAmount *= 2;
}



double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

double overAllTotalFareAmount = baseFareAmount + (totalDistanceTravelFareAmount + totalDurationSpendFareAmount);

// Calculate tax amount only if totalTaxAmount is greater than 0
double overallTotalTaxAmount = 0.0;
if (totalTaxAmount > 0) {
  overallTotalTaxAmount = overAllTotalFareAmount * totalTaxAmount / 100;
}

double finalFareAmount = overAllTotalFareAmount + overallTotalTaxAmount;


return finalFareAmount.toStringAsFixed(1);

}


//calculateFareAmountFor4Seats


Future<String> calculateFareAmountFor4Seats(DirectionDetails directionDetails) async {
  double distancePerKmAmount = 0.0;
  double durationPerMinuteAmount = 0;
  double baseFareAmount = 0;
  double totalTaxAmount = 0;
  double radiusValue = 0; // Variable to store radius data

  // Get reference to fareData
  DatabaseReference fareDataRef = FirebaseDatabase.instance.ref().child('fareData').child('SUVs');
  // Get reference to radiusData
  DatabaseReference radiusDataRef = FirebaseDatabase.instance.ref().child('radiusData').child("SUVs");

  // Fetch the fare data from Firebase
  DataSnapshot fareSnapshot = await fareDataRef.get();
  // Fetch the radius data from Firebase
  DataSnapshot radiusSnapshot = await radiusDataRef.get();

  if (fareSnapshot.exists) {
    // Extract data from the fareSnapshot
    double vehicleFare = double.parse(fareSnapshot.child('vehicle Fare').value.toString());
    double kmFare = double.parse(fareSnapshot.child('kmFare').value.toString().replaceAll('/km', ''));
    double minutesFare = double.parse(fareSnapshot.child('Minutes Fare').value.toString());
    double taxAmount = double.parse(fareSnapshot.child('taxAmount (Gst)').value.toString());

    baseFareAmount = vehicleFare;
    distancePerKmAmount = kmFare;
    durationPerMinuteAmount = minutesFare;
    totalTaxAmount = taxAmount;
    
    
print("4444444444444444+++++++++++baseFareAmount+++++++++++++++++$baseFareAmount");
print("+++++++++++distancePerKmAmount+++++++++++++++++$distancePerKmAmount");

print("+++++++++++durationPerMinuteAmount+++++++++++++++++$durationPerMinuteAmount");
print("+++++++++++totalTaxAmount+++++++++++++++++$totalTaxAmount");
    
    
  } else {
    return "Fare data not available";
  }

 double radiusInMeters; // Declare radiusInMeters outside the if-else block

if (radiusSnapshot.exists) {
  // Extract data from the radiusSnapshot
  radiusValue = double.parse(radiusSnapshot.child('radius').value.toString());
  

print("============================radiusValue==============================$radiusValue");

  // Convert radiusValue from kilometers to meters
  radiusInMeters = radiusValue * 1000;
  
print("=====================radiusInMeters==========================$radiusInMeters");

} else {
  // Handle case where radius data is not available
  radiusValue = 0; // Default value or handle as needed

  // Convert radiusValue from kilometers to meters (will still be 0)
  radiusInMeters = radiusValue * 1000;

print("+++++++++++radiusInMeters+++++++++++++++++$radiusInMeters");
}

// Calculate fare based on directionDetails and radiusAmount
double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;


print("+++++++++++totalDistanceTravelFareAmount+++++++++++++++++$totalDistanceTravelFareAmount");

// Adjust the fare amount based on radiusInMeters if it's greater than 0


print("====222222222222222222222222222222222=============radiusInMeters===================$radiusInMeters");

print("====111111111===============radiusInMeters===================${ directionDetails.distanceValueDigits}");
if (radiusInMeters < directionDetails.distanceValueDigits!) {

  totalDistanceTravelFareAmount *= 2;
}





double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

print("====111111111===============totalDurationSpendFareAmount===================$totalDurationSpendFareAmount");

double overAllTotalFareAmount = baseFareAmount + (totalDistanceTravelFareAmount + totalDurationSpendFareAmount);

print("===================overAllTotalFareAmount===================$overAllTotalFareAmount");


// Calculate tax amount only if totalTaxAmount is greater than 0
double overallTotalTaxAmount = 0.0;
if (totalTaxAmount > 0) {
  overallTotalTaxAmount = overAllTotalFareAmount * totalTaxAmount / 100;
}

double finalFareAmount = overAllTotalFareAmount + overallTotalTaxAmount;


return finalFareAmount.toStringAsFixed(1);

}


  //calculateFareAmountFor7Seats

Future<String> calculateFareAmountFor7Seats(DirectionDetails directionDetails) async {
  double distancePerKmAmount = 0.0;
  double durationPerMinuteAmount = 0;
  double baseFareAmount = 0;
  double totalTaxAmount = 0;
  double radiusValue = 0; // Variable to store radius data

  // Get reference to fareData
  DatabaseReference fareDataRef = FirebaseDatabase.instance.ref().child('fareData').child('Premium');
  // Get reference to radiusData
  DatabaseReference radiusDataRef = FirebaseDatabase.instance.ref().child('radiusData').child("Premium");

  // Fetch the fare data from Firebase
  DataSnapshot fareSnapshot = await fareDataRef.get();
  // Fetch the radius data from Firebase
  DataSnapshot radiusSnapshot = await radiusDataRef.get();

  if (fareSnapshot.exists) {
    // Extract data from the fareSnapshot
    double vehicleFare = double.parse(fareSnapshot.child('vehicle Fare').value.toString());
    double kmFare = double.parse(fareSnapshot.child('kmFare').value.toString().replaceAll('/km', ''));
    double minutesFare = double.parse(fareSnapshot.child('Minutes Fare').value.toString());
    double taxAmount = double.parse(fareSnapshot.child('taxAmount (Gst)').value.toString());

    baseFareAmount = vehicleFare;
    distancePerKmAmount = kmFare;
    durationPerMinuteAmount = minutesFare;
    totalTaxAmount = taxAmount;
    
print("7777777777777777+++++++++++baseFareAmount+++++++++++++++++$baseFareAmount");
print("=======================distancePerKmAmount====================$distancePerKmAmount");

print("----------------------durationPerMinuteAmount----------------------$durationPerMinuteAmount");
print("+++++++++++totalTaxAmount+++++++++++++++++$totalTaxAmount");
    

  } else {
    return "Fare data not available";
  }


 double radiusInMeters; // Declare radiusInMeters outside the if-else block

if (radiusSnapshot.exists) {
  // Extract data from the radiusSnapshot
  radiusValue = double.parse(radiusSnapshot.child('radius').value.toString());

  // Convert radiusValue from kilometers to meters
  radiusInMeters = radiusValue * 1000;
  

print("----------------------radiusInMeters----------------------$radiusInMeters");
} else {
  // Handle case where radius data is not available
  radiusValue = 0; // Default value or handle as needed

  // Convert radiusValue from kilometers to meters (will still be 0)
  radiusInMeters = radiusValue * 1000;
  

}

// Calculate fare based on directionDetails and radiusAmount
double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;


print("----------------------directionDetails.distanceValueDigits----------------------${directionDetails.distanceValueDigits}");

print("----------------------totalDistanceTravelFareAmount----------------------$totalDistanceTravelFareAmount");

// Adjust the fare amount based on radiusInMeters if it's greater than 0

print("----------------------radiusInMeters----------------------$radiusInMeters");

print("----------------------radiusInMeters----------------------${directionDetails.distanceValueDigits}");
if (radiusInMeters < directionDetails.distanceValueDigits!) {
  
  totalDistanceTravelFareAmount *= 2;

  
  
  
}



double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;


print("----------------------totalDurationSpendFareAmount----------------------$totalDurationSpendFareAmount");
double overAllTotalFareAmount = baseFareAmount + (totalDistanceTravelFareAmount + totalDurationSpendFareAmount);


print("----------------------overAllTotalFareAmount----------------------$overAllTotalFareAmount");

// Calculate tax amount only if totalTaxAmount is greater than 0
double overallTotalTaxAmount = 0.0;
if (totalTaxAmount > 0) {
  
  overallTotalTaxAmount = overAllTotalFareAmount * totalTaxAmount / 100;
}

double finalFareAmount = overAllTotalFareAmount + overallTotalTaxAmount;

return finalFareAmount.toStringAsFixed(1);

}

 

 

  // Return a default value or error message when snapshot does not exist

}