// ignore_for_file: file_names, deprecated_member_use, depend_on_referenced_packages, duplicate_ignore, use_build_context_synchronously, library_prefixes
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:journal/widgets/Post.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as Path;

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<File> _images = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _cityName = '';
  DateTime _day = DateTime.now();

  var latitude = 0.0;
  var longitude = 0.0;

  late SharedPreferences prefs;

  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${Path.basename(imageFile.path)}';
    final savedImage = await imageFile.copy(imagePath);
    return savedImage.path;
  }

  Future<void> _saveData() async {
    prefs = await SharedPreferences.getInstance();
    // Save the data
    await prefs.setString('title', _titleController.text);
    await prefs.setString('description', _descriptionController.text);
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    await prefs.setString('city', _cityName);
    await prefs.setString('day', _day.toString());
    await prefs.setStringList(
        'images', _images.map((image) => image.path).toList());
  }

  void _loadData() async {
    prefs = await SharedPreferences.getInstance();

    // Load the data
    setState(() {
      _titleController.text = prefs.getString('title') ?? '';
      _descriptionController.text = prefs.getString('description') ?? '';
      latitude = (prefs.getDouble('latitude') ?? 0.0);
      longitude = (prefs.getDouble('longitude') ?? 0.0);
      _cityName = (prefs.getString('city') ?? '');
      //_day = DateTime.parse((prefs.getString('day') ?? ''));
      _day = DateTime.now();
      List<String> imagePaths = prefs.getStringList('images') ?? [];
      _images = imagePaths.map((path) => File(path)).toList();
    });
  }

  void _newPost() {
    _titleController.clear();
    _descriptionController.clear();
    _images.clear();
    setState(() {
      _cityName = '';
      latitude = 0.0;
      longitude = 0.0;
      _day = DateTime.now();
    });
  }

  // Define functions to handle button presses
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

  void _savePost() {
    if (_titleController.value.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must add a title !')));
    } else if (_descriptionController.value.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must add a description !')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Post saved !'),
        backgroundColor: Color.fromARGB(255, 46, 118, 48),
      ));
      _saveData();
    }
  }

  void _submit() async {
    if (_titleController.value.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must add a title !')));
    } else if (_descriptionController.value.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must add a description !')));
    } else {
      // Add code to save the post to the database

      // Create a new Post object with the form values
      List<String> imagePaths =
          await Future.wait(_images.map((imageFile) => saveImage(imageFile)));
      final post = Post(
        title: _titleController.text,
        description: _descriptionController.text,
        images: imagePaths,
        videos: [],
        locationName: _cityName,
        locationCoords: LatLng(latitude, longitude),
        date: DateTime.now(),
      );
      // Insert the post into the database
      await DatabaseHelper.instance.insertPost(post);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Post submited !'),
        backgroundColor: Color.fromARGB(255, 46, 118, 48),
      ));
      _titleController.clear();
      _descriptionController.clear();
      _images.clear();
      setState(() {
        _cityName = '';
        latitude = 0.0;
        longitude = 0.0;
        _day = DateTime.now();
      });
      _saveData();
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              actions: [
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.purple),
                  onPressed: _newPost,
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
                  onPressed: _savePost,
                ),
                const Expanded(child: SizedBox()),
                IconButton(
                  icon: const Icon(Icons.upload, color: Colors.purple),
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
                        style: const TextStyle(color: Colors.white),
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
    );
  }
}
