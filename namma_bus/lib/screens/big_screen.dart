import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:namma_bus/Assistants/assistant_methods.dart';
import 'package:namma_bus/DataHandler/app_data.dart';
import 'package:namma_bus/generate_qr_code.dart';
import 'package:namma_bus/screens/pass_page.dart';

import 'package:namma_bus/screens/searchs_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = -1;
  bool isLoading = true;
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;
  List<Map<String, dynamic>> busList = [];

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.88478821997547, 74.87748305333244),
    zoom: 10,
  );

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geolocation = Geolocator();

  LocationPermission? _locationPermission;

  double bottomPaddingOfMap = 0;
  List<int> remainingTimes = [];
  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  double rideContainerHeight = 0;
  double searchContainerHeight = 300;
  //String userName = "";
  // String userEmail="";

  void displayRideDetailsContainer() async {
    setState(() {
      searchContainerHeight = 0;
      rideContainerHeight = 740;
    });
  }

  void exdisplayRideDetailsContainer() async {
    setState(() {
      searchContainerHeight = 340;
      rideContainerHeight = 0;
    });
  }

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  void locateUserPosition() async {
    print("HIIIIIII");
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(cPosition.latitude, cPosition.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    _address =
        await AssistantMethods.searchCoordinateAddress(cPosition, context);
    print("Your Address :: $_address");
  }

  getLocationFromLatLng() async {
    try {
      List<Placemark> pointer = await placemarkFromCoordinates(
          pickLocation!.latitude, pickLocation!.longitude);

      _address = pointer.reversed.last.street.toString() +
          pointer.reversed.last.locality.toString() +
          pointer.reversed.last.postalCode.toString();
    } catch (e) {
      print(e);
    }
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void updateRemainingTimes() {
    if (busList.isEmpty) {
      return; // Exit early if busList is empty
    }

    DateTime now = DateTime.now();
    List<int> updatedRemainingTimes = [];

    for (Map<String, dynamic> busInfo in busList) {
      String departureTimeString = busInfo['time'];
      DateTime departureTime =
          DateFormat("HH:mm:ss").parse(departureTimeString);

      // Ensure departureTime is set to today
      departureTime = DateTime(now.year, now.month, now.day, departureTime.hour,
          departureTime.minute, departureTime.second);

      // Calculate time difference
      int minutesDifference = departureTime.isAfter(now)
          ? departureTime.difference(now).inMinutes
          : 24 * 60 + departureTime.difference(now).inMinutes;

      updatedRemainingTimes.add(minutesDifference);
    }

    setState(() {
      if (busList.length == updatedRemainingTimes.length) {
        remainingTimes = updatedRemainingTimes;
      }
    });
  }

  TextEditingController cntrller = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    Timer.periodic(const Duration(minutes: 1), (Timer t) {
      updateRemainingTimes();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      remainingTimes = List<int>.filled(busList.length, 0);
    });
  }

  Future<void> fetchData() async {
    try {
      // Set loading state to true
      setState(() {
        isLoading = true;
      });

      // Perform the asynchronous operation to fetch data
      var res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchScreen(),
        ),
      );

      // Update the state with fetched data
      updateStateWithData(res);
    } catch (e) {
      // Handle any exceptions that might occur during data fetch
      print("Error during data fetch: $e");
      // Set loading state to false in case of an error
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateStateWithData(dynamic res) {
    if (res != null && res is List && res.isNotEmpty) {
      setState(() {
        busList = List<Map<String, dynamic>>.from(res);
        isLoading = false;
        // Call displayRideDetailsContainer after updating the state
        displayRideDetailsContainer();
      });
    } else {
      // Handle the case where the response is null or empty
      print("No data received from SearchScreen or the data is empty.");
      // Set loading state to false in case of an issue
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
              body: Stack(children: [
            GoogleMap(
              compassEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                newGoogleMapController = controller;
                setState(() {});

                locateUserPosition();
              },
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
            ),
            Positioned(
                top: 20,
                left: 20,
                child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Color(0xFFFFF7E8))),
                  onPressed: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()))
                  },
                  child: const Text(
                    "Bus Pass",
                    style: TextStyle(
                      color: Color(0xffFF8700),
                    ),
                  ),
                )),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 160),
                curve: Curves.bounceIn,
                child: Container(
                  height: searchContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade500,
                            blurRadius: 16,
                            spreadRadius: 0.5,
                            offset: const Offset(0.7, 0.7))
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 6,
                        ),
                        const Text(
                          "Hi There",
                          style: TextStyle(fontSize: 12),
                        ),
                        const Text(
                          "Where To?",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await fetchData();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade500,
                                      blurRadius: 3)
                                ]),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Search Drop Off Location",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.home,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: Text(
                                    Provider.of<AppData>(context)
                                                .pickUpLocation !=
                                            null
                                        ? Provider.of<AppData>(context)
                                                .pickUpLocation!
                                                .placeName ??
                                            "Loading.."
                                        : "Loading..",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                const Text(
                                  "Your living Address",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          height: 10,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.work,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Work",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "Your Office Address",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                )
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
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 160),
                curve: Curves.bounceIn,
                child: Container(
                  height: rideContainerHeight,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 16,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      top: 18,
                                      bottom: 0,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: exdisplayRideDetailsContainer,
                                      child: const Icon(Icons.arrow_back),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 1, vertical: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isLoading) // Show loading indicator if data is still loading
                                              const CircularProgressIndicator(),
                                            if (!isLoading && busList.isEmpty)
                                              const Text(
                                                  "No data available"), // Show message when data is empty
                                            if (!isLoading &&
                                                busList.isNotEmpty)
                                              busList.isNotEmpty &&
                                                      busList.length ==
                                                          remainingTimes.length
                                                  ? ListView.builder(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemExtent: 90,
                                                      shrinkWrap: true,
                                                      itemCount: busList
                                                                  .isNotEmpty &&
                                                              busList.length ==
                                                                  remainingTimes
                                                                      .length
                                                          ? busList.length
                                                          : 0,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        Map<String, dynamic>
                                                            busInfo =
                                                            busList[index];
                                                        String busName =
                                                            busInfo['bus_name'];
                                                        String destination =
                                                            busInfo[
                                                                'destination'];
                                                        int minutesDifference =
                                                            remainingTimes[
                                                                index];

                                                        return GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedIndex =
                                                                  index; // Update the selected index
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              ListTile(
                                                                leading:
                                                                    const Icon(
                                                                  Icons
                                                                      .directions_bus,
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                                title: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        busName),
                                                                    Text(
                                                                      'In $minutesDifference min⬇',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                subtitle: Text(
                                                                    destination),
                                                                tileColor: selectedIndex ==
                                                                        index
                                                                    ? Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.9) // Highlight color when selected
                                                                    : null, // Use null if no highlighting is needed
                                                              ),
                                                              const Divider(
                                                                height: 5,
                                                                thickness: 2,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : const CircularProgressIndicator(),

                                            const SizedBox(width: 16),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  size: 13,
                                ),
                                SizedBox(height: 16),
                                Text("Cash"),
                                SizedBox(
                                  width: 6,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const GenerateQRCode()));
                                  });
                                },
                                style: const ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.amber)),
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Buy Ticket",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]))),
    );
  }
}

class BusListItem extends StatelessWidget {
  final String busName;
  final String destination;

  const BusListItem({required this.busName, required this.destination});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.directions_bus, color: Colors.blue),
      title: Text(busName),
      subtitle: Text(destination),
      onTap: () {
        // Handle the tap on the bus item if needed
      },
    );
  }
}
