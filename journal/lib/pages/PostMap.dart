// ignore_for_file: depend_on_referenced_packages, file_names

import 'package:journal/widgets/Post.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:connectivity/connectivity.dart';

class PostMap extends StatefulWidget {
  final Post post;
  const PostMap({super.key, required this.post});

  @override
  State<PostMap> createState() => _PostMapState();
}

class _PostMapState extends State<PostMap> {
  late MapController _mapController;
  late final Connectivity _connectivity;
  late final ScaffoldMessengerState _scaffoldMessenger;

  Future<void> _checkInternetConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
        ),
      );
    }
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

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    _connectivity = Connectivity();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _checkInternetConnectivity();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: widget.post.locationCoords,
          zoom: 15,
          maxZoom: 18.0, // maximum zoom level
          minZoom: 4.0, // minimum zoom level
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            maxZoom: 20,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.post.locationCoords,
                builder: (ctx) => GestureDetector(
                  child: const Icon(
                    Icons.location_pin,
                    size: 35,
                    color: Colors.purple,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Column(children: [
                          Text(widget.post.title),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.post.locationName,
                                style: const TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                              const Expanded(child: SizedBox()),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a')
                                    .format(widget.post.date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          )
                        ]),
                        content: text(widget.post.description),
                        actions: [
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                anchorPos: AnchorPos.align(AnchorAlign.top),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: _zoomIn,
            tooltip: 'Zoom in',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: _zoomOut,
            tooltip: 'Zoom out',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
