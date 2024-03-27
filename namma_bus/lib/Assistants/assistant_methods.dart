import 'package:geolocator/geolocator.dart';
import 'package:namma_bus/Assistants/request_Assistant.dart';
import 'package:namma_bus/Models/address.dart';
import 'package:namma_bus/globals/map_key.dart';
import 'package:provider/provider.dart';
import 'package:namma_bus/DataHandler/app_data.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    // print(position.latitude);
    // print(position.longitude);
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";

    try {
      var response = await RequestAssistant.getRequest(url);
      print("RESSSSSSponse:$response");

      if (response != "Failed") {
        String str1 =
            response["results"][0]["address_components"][1]["long_name"];
        placeAddress = str1;

        Address userPickUpAddress = Address();
        userPickUpAddress.latitude = position.latitude;
        userPickUpAddress.longitude = position.longitude;
        userPickUpAddress.placeName = placeAddress;

        Provider.of<AppData>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);
      }
    } catch (e) {
      print("BIGERROR:::::${e.toString()}");
    }

    return placeAddress;
  }
}
