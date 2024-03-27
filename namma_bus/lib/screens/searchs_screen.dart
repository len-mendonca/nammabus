import 'package:flutter/material.dart';
import 'package:namma_bus/Assistants/request_assistant.dart';
import 'package:namma_bus/DataHandler/app_data.dart';
import 'package:namma_bus/Models/address.dart';
import 'package:namma_bus/Models/place_predictions.dart';
import 'package:namma_bus/globals/map_key.dart';
import 'package:provider/provider.dart';
import 'package:namma_bus/screens/big_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation?.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;

    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                const Center(
                  child: Text(
                    "Set Drop Off",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              width: 0.8 * MediaQuery.of(context).size.width,
              height: 50.0,
              decoration: const BoxDecoration(
                color: Color(0xffFFF7E8),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextField(
                controller: pickUpTextEditingController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_on_sharp,
                    color: Color(0xffFF8700),
                  ),
                  hintText: 'Pick Up Location',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xffFF8700)),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              width: 0.8 * MediaQuery.of(context).size.width,
              height: 50.0,
              decoration: const BoxDecoration(
                color: Color(0xffFFF7E8),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextField(
                controller: dropOffTextEditingController,
                onChanged: (val) {
                  findPlace(val);
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_on_sharp,
                    color: Color(0xffFF8700),
                  ),
                  hintText: 'Drop Off Location',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xffFF8700)),
                ),
              ),
            ),
            (placePredictionList.isNotEmpty)
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 300,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromARGB(255, 255, 251, 251),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffe7e7e7),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        )
                      ],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                          press: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                            // ignore: avoid_print
                            print(
                                "HI the PlacEEEEEEEEEE ${placePredictionList[index]}");
                          },
                          placePredictions: placePredictionList[index],
                        );
                      },
                      itemCount: placePredictionList.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          height: 1,
                          color: Colors.grey.shade300,
                          indent: 10,
                          endIndent: 10,
                        );
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.isNotEmpty) {
      String autocompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&types=geocode&key=$apiKey&components=country:in";

      var res = await RequestAssistant.getRequest(autocompleteUrl);

      if (res == "Failed") {
        return;
      }

      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  final VoidCallback press;

  const PredictionTile({
    super.key,
    required this.placePredictions,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.add_location, color: Color(0xffFF8700)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placePredictions.main_text ?? " ",
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        placePredictions.secondary_text ?? " ",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String? placeId, context) async {
    var te;
    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";
    var res = await RequestAssistant.getRequest(placeDetailsUrl);

    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      // ignore: avoid_print
      print("Hi your new address is ${address.placeName}");

      String destination =
          address.placeName.toString(); // Assuming placeName is the destination
      String queryUrl =
          "http://192.168.56.1:3000/api/buses/q?destination=$destination";

      var serverResponse = await RequestAssistant.getRequest(queryUrl);

      if (serverResponse != "Failed" && serverResponse is List) {
        // Handle the server response (list of matching buses)
        // For example, update the UI or perform further actions
        // ignore: avoid_print
        print("Server Response: $serverResponse");
      } else if (serverResponse.containsKey('message')) {
        // Handle the case where no matching buses are found
        // ignore: avoid_print
        print("No Matching Buses: ${serverResponse['message']}");
      }

      te = serverResponse ?? " ";

      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
    }
    Navigator.pop(context, te);
  }
}
