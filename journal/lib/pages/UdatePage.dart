// ignore_for_file: file_names, depend_on_referenced_packages, duplicate_ignore, deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:journal/widgets/Post.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class UpdatePage extends StatefulWidget {
  final Post post;
  const UpdatePage({super.key, required this.post});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final List<File> _images = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _cityName = '';
  DateTime _day = DateTime.now();

  double latitude = 0.0;
  double longitude = 0.0;

  //int? id;
  String title = '';
  String description = '';
  List<String>? images;
  List<String>? videos;
  String locationName = '';
  LatLng locationCoords = LatLng(0, 0);
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize the form fields with the values from the Post object passed in from the previous screen
    _titleController.text = widget.post.title;
    _descriptionController.text = widget.post.description;
    _cityName = widget.post.locationName;
    _day = widget.post.date;
    latitude = widget.post.locationCoords.latitude;
    longitude = widget.post.locationCoords.longitude;

    // Load the images for the post
    for (var path in widget.post.images!) {
      if (path.length > 10) {
        _images.add(File(path));
      }
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _selectImage() async {
    // Add code to select an image and add it to the _images list
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Do something with the picked image
      File imageFile = File(pickedFile.path);
      // Add the image file to the list
      setState(() {
        _images.add(imageFile);
      });
    }
  }

  Future<String> getCityName(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final city = jsonResponse['address']['city'];
      return city;
    } else {
      throw Exception('Failed to get city name');
    }
  }

  void _getLocation() async {
    final location = await Geolocator.getCurrentPosition();
    final cityName = await getCityName(location.latitude, location.longitude);
    setState(() {
      latitude = location.latitude;
      longitude = location.longitude;
      _cityName = cityName;
    });
  }

  void _submit() async {
    if (_titleController.value.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must add a title !')));
    } else if (_descriptionController.value.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must add a description !')));
    } else {
      List<String>? imagePaths = [];
      for (var file in _images) {
        imagePaths.add(file.path.toString());
      }
      setState(() {
        title = _titleController.text;
        description = _descriptionController.text;
        images = imagePaths;
        videos = [];
        locationName = _cityName;
        locationCoords = LatLng(latitude, longitude);
      });
      final post = Post(
        title: title,
        description: description,
        images: images,
        videos: videos,
        locationName: locationName,
        locationCoords: locationCoords,
        date: widget.post.date,
      );
      // Insert the post into the database
      await DatabaseHelper.instance.updatePost(widget.post, post);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Post updated !'),
        backgroundColor: Color.fromARGB(255, 46, 118, 48),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                actions: [
                  const Expanded(child: SizedBox()),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.purple),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.purple),
                    onPressed: _takePicture,
                  ),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.purple),
                    onPressed: _selectImage,
                  ),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Colors.purple),
                    onPressed: _getLocation,
                  ),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.purple),
                    onPressed: _submit,
                  ),
                  const Expanded(child: SizedBox()),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(
                      50), // set the height of the TextField
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(_day),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black45),
                        ),
                        TextField(
                          style: const TextStyle(fontSize: 25),
                          controller:
                              _titleController, // set the controller for the TextField
                          decoration: const InputDecoration(
                            hintText: 'Enter title',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Write your description here',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              bottomNavigationBar: _images.isEmpty
                  ? null
                  : BottomAppBar(
                      color: Colors.black12,
                      elevation: 0,
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Image.file(_images[index]),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )),
          _cityName.isEmpty
              ? const SizedBox()
              : Positioned(
                  bottom: _images.isEmpty ? 20 : 120,
                  right: 10,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _cityName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _cityName = '';
                              latitude = 0.0;
                              longitude = 0.0;
                            });
                          },
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.white54,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
