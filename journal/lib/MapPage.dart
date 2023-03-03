// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:journal/pages/PostDetailsPage.dart';
import 'package:journal/widgets/Post.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  final List<Post> posts;
  const MapPage({super.key, required this.posts});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;
  LatLng? _center; // make it nullable
  final List<Marker> _markers = [];
  //double _currentZoom = 15.0;
  final double _maxZoom = 18.0;
  final double _minZoom = 4.0;
  late double _currentZoom = 15.0;
  final bool _isZoomInDisabled = false;
  final bool _isZoomOutDisabled = false;
  late LocationData locationData;
  var latitude = 0.0;
  var longitude = 0.0;

  late SharedPreferences prefs;
  Future<void> _saveData() async {
    prefs = await SharedPreferences.getInstance();
    // Save the data
    setState(() {
      _center = LatLng(locationData.latitude!, locationData.longitude!);
    });
    prefs.setDouble('latitude', locationData.latitude!);
    prefs.setDouble('longitude', locationData.longitude!);
  }

  Future<void> _loadData() async {
    prefs = await SharedPreferences.getInstance();
    // Load the data
    setState(() {
      latitude = (prefs.getDouble('latitude') ?? 0.0);
      longitude = (prefs.getDouble('longitude') ?? 0.0);
      _center = LatLng(latitude, longitude);
      _currentMarker();
      _mapController.move(_center!, 15);
    });
  }

  Widget text(String desc) {
    if (desc.length > 100) {
      return Text(
        '${desc.substring(0, 100).replaceAll('\n', ' ')}${desc.length > 100 ? '...' : ''}',
        style: const TextStyle(
          fontSize: 16.0,
        ),
      );
    } else {
      return Text(
        desc.replaceAll('\n', ' '),
        style: const TextStyle(
          fontSize: 16.0,
        ),
      );
    }
  }

  bool _visible = true;
  Future _isVisible() async {
    if (_currentZoom > 9.0) {
      setState(() {
        _visible = true;
      });
    } else {
      setState(() {
        _visible = false;
      });
    }
  }

  Future _addMarkers() async {
    for (var post in widget.posts) {
      if (post.locationCoords.latitude != 0.0 &&
          post.locationCoords.longitude != 0.0) {
        var marker = Marker(
          point: post.locationCoords,
          builder: (ctx) => GestureDetector(
            child: Icon(
              Icons.location_pin,
              size: 35,
              color: _visible ? Colors.purple : Colors.transparent,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Column(children: [
                    Text(post.title),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          post.locationName,
                          style: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                        const Expanded(child: SizedBox()),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(post.date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    )
                  ]),
                  content: text(post.description),
                  actions: [
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('See Post'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostDetailPage(post: post)),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          anchorPos: AnchorPos.align(AnchorAlign.top),
        );
        _markers.add(marker);
      }
    }
  }

  void _currentMarker() {
    if (_center != null && latitude != 0.0 && longitude != 0.0) {
      var marker = Marker(
        point: _center ?? LatLng(0, 0),
        builder: (context) => const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      );
      _markers.add(marker);
    }
  }

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
    setState(() {
      _currentZoom += 1;
    });
    _isVisible();
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
    setState(() {
      _currentZoom -= 1;
    });
    _isVisible();
  }

  void _getLocation() async {
    var location = Location();
    try {
      locationData = await location.getLocation();
    } catch (e) {
      print("Could not get location: $e");
      return;
    }
    setState(() {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
      _center = LatLng(locationData.latitude!, locationData.longitude!);
      _mapController.move(_center!, 15);
    });
  }

  @override
  void initState() {
    _mapController = MapController();
    _loadData();
    _getLocation();
    _addMarkers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _center,
          zoom: 15,
          maxZoom: _maxZoom, // maximum zoom level
          minZoom: _minZoom, // minimum zoom level
          bounds: LatLngBounds(LatLng(48.8156, 2.2246),
              LatLng(48.8156, 2.2246)), // bounding box for the map
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            maxZoom: 20,
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _getLocation();
              _saveData();
            },
            tooltip: 'Get current location',
            child: const Icon(Icons.location_searching),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _zoomIn,
            tooltip: 'Zoom in',
            backgroundColor: _isZoomInDisabled
                ? Colors.grey
                : Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _zoomOut,
            tooltip: 'Zoom out',
            backgroundColor: _isZoomOutDisabled
                ? Colors.grey
                : Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
