import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

class SampleNavigationApp extends StatefulWidget {
  const SampleNavigationApp({super.key});

  @override
  _SampleNavigationAppState createState() => _SampleNavigationAppState();
}

class _SampleNavigationAppState extends State<SampleNavigationApp> {
  String? _platformVersion;
  String? _instruction;
  final _origin = WayPoint(
      name: "Way Point 1",
      latitude: 38.9111117447887,
      longitude: -77.04012393951416);
  final _stop1 = WayPoint(
      name: "Way Point 2",
      latitude: 38.91113678979344,
      longitude: -77.03847169876099);
  final _stop2 = WayPoint(
      name: "Way Point 3",
      latitude: 38.91040213277608,
      longitude: -77.03848242759705);
  final _stop3 = WayPoint(
      name: "Way Point 4",
      latitude: 38.909650771013034,
      longitude: -77.03850388526917);
  final _destination = WayPoint(
      name: "Way Point 5",
      latitude: 38.90894949285854,
      longitude: -77.03651905059814);

  final _home = WayPoint(
      name: "Home",
      latitude: 37.77440680146262,
      longitude: -122.43539772352648);

  final _store = WayPoint(
      name: "Store",
      latitude: 37.76556957793795,
      longitude: -122.42409811526268);

  final _dentist = WayPoint(
    name: "Dentist",
    latitude: 27.9151,
    longitude: -82.5057,
  );

  final _riverWalk = WayPoint(
    name: "River Walk",
    latitude: 27.9447,
    longitude: -82.4588,
  );

  bool _isMultipleStop = false;
  double? _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController? _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  late MapBoxOptions _navigationOption;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _navigationOption = MapBoxNavigation.instance.getDefaultOptions();
    _navigationOption.simulateRoute = Platform.isIOS;
    _navigationOption.mapStyleUrlDay =
        'mapbox://styles/mapbox/navigation-night-v1';
    _navigationOption.mapStyleUrlNight =
        'mapbox://styles/mapbox/navigation-night-v1';

    //_navigationOption.initialLatitude = 36.1175275;
    //_navigationOption.initialLongitude = -115.1839524;
    MapBoxNavigation.instance.registerRouteEventListener(_onEmbeddedRouteEvent);
    MapBoxNavigation.instance.setDefaultOptions(_navigationOption);

    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await MapBoxNavigation.instance.getPlatformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Running on: $_platformVersion\n'),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Full Screen Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text("Start A to B"),
                          onPressed: () async {
                            var wayPoints = <WayPoint>[];
                            wayPoints.add(_dentist);
                            wayPoints.add(_riverWalk);

                            await MapBoxNavigation.instance
                                .startNavigation(wayPoints: wayPoints);
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: const Text("Start Multi Stop"),
                          onPressed: () async {
                            _isMultipleStop = true;
                            var wayPoints = <WayPoint>[];
                            wayPoints.add(_origin);
                            wayPoints.add(_stop1);
                            wayPoints.add(_stop2);
                            wayPoints.add(_stop3);
                            wayPoints.add(_destination);

                            MapBoxNavigation.instance.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(
                                    mode: MapBoxNavigationMode.driving,
                                    simulateRoute: true,
                                    language: "en",
                                    allowsUTurnAtWayPoints: true,
                                    units: VoiceUnits.metric));
                            //after 10 seconds add a new stop
                            await Future.delayed(const Duration(seconds: 10));
                            var stop = WayPoint(
                                name: "Gas Station",
                                latitude: 38.911176544398,
                                longitude: -77.04014366543564);
                            MapBoxNavigation.instance
                                .addWayPoints(wayPoints: [stop]);
                          },
                        )
                      ],
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Embedded Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isNavigating
                              ? null
                              : () {
                                  if (_routeBuilt) {
                                    _controller?.clearRoute();
                                  } else {
                                    var wayPoints = <WayPoint>[];
                                    wayPoints.add(_home);
                                    wayPoints.add(_store);
                                    _isMultipleStop = wayPoints.length > 2;
                                    _controller?.buildRoute(
                                        wayPoints: wayPoints,
                                        options: _navigationOption);
                                  }
                                },
                          child: Text(_routeBuilt && !_isNavigating
                              ? "Clear Route"
                              : "Build Route"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: const Text("Start "),
                          onPressed: _routeBuilt && !_isNavigating
                              ? () {
                                  _controller?.startNavigation();
                                }
                              : null,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: const Text("Cancel "),
                          onPressed: _isNavigating
                              ? () {
                                  _controller?.finishNavigation();
                                }
                              : null,
                        )
                      ],
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Long-Press Embedded Map to Set Destination",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: (Text(
                          _instruction == null
                              ? "Banner Instruction Here"
                              : _instruction!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, top: 20, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Text("Duration Remaining: "),
                              Text(_durationRemaining != null
                                  ? "${(_durationRemaining! / 60).toStringAsFixed(0)} minutes"
                                  : "---")
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              const Text("Distance Remaining: "),
                              Text(_distanceRemaining != null
                                  ? "${(_distanceRemaining! * 0.000621371).toStringAsFixed(1)} miles"
                                  : "---")
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider()
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await MapBoxNavigation.instance.getDistanceRemaining();
    _durationRemaining = await MapBoxNavigation.instance.getDurationRemaining();
    log('Route Event: ${e.eventType}');

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) {
          _instruction = progressEvent.currentStepInstruction;
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));

          await MapBoxNavigation.instance.finishNavigation();
          //await _controller?.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }
}
