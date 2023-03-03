// ignore_for_file: library_private_types_in_public_api, file_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:journal/widgets/Post.dart';

import 'AddPostPage.dart';
import 'MapPage.dart';
import 'PostPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Post> posts = [
    /* Post(
        title: "My first post",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit jklqsdjlqsd qsljdklqs qsjdklqsjdl qsjdklqjdlq kslmqkdlq.",
        images: [
          'https://picsum.photos/id/9/200/200',
          'https://picsum.photos/id/7/200/200',
        ],
        videos: [],
        locationName: "Rabat",
        locationCoords: LatLng(33.9715904, -6.8498129),
        date: DateTime.now()),
    Post(
        title: "My second post",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit jklqsdjlqsd qsljdklqs qsjdklqsjdl qsjdklqjdlq kslmqkdlq.",
        images: [],
        videos: [],
        locationName: "Salé",
        locationCoords: LatLng(34.043373, -6.798694),
        date: DateTime.now()),
    Post(
        title: "My third post",
        description: "Lorem",
        images: [
          'https://picsum.photos/id/15/200/200',
          'https://picsum.photos/id/16/200/200',
          'https://picsum.photos/id/17/200/200',
          'https://picsum.photos/id/18/200/200',
          'https://picsum.photos/id/19/200/200',
        ],
        videos: [],
        locationName: "Tanger",
        locationCoords: LatLng(35.759465, -5.833954),
        date: DateTime.now()), */
  ];
  void loadPosts() async {
    final postsList = await DatabaseHelper.instance.getPosts();
    setState(() {
      posts = postsList;
      _widgetOptions = [
        PostsPage(
          posts: posts,
        ),
        const AddPostPage(),
        MapPage(
          posts: posts,
        ),
      ];
    });
  }

  late List<Widget> _widgetOptions = [
    const Center(
      child: CircularProgressIndicator(
        color: Colors.purple,
      ),
    ),
    const AddPostPage(),
    const Center(
      child: CircularProgressIndicator(
        color: Colors.purple,
      ),
    )
  ];

  bool _isHome = true;
  bool _isMap = false;
  bool _isAdd = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _isHome = true;
        _isMap = false;
        _isAdd = false;
      }
      if (_selectedIndex == 1) {
        _isHome = false;
        _isMap = false;
        _isAdd = true;
      }
      if (_selectedIndex == 2) {
        _isHome = false;
        _isMap = true;
        _isAdd = false;
      }
    });
  }

  @override
  void initState() {
    loadPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loadPosts();
    return Scaffold(
        appBar: _isAdd
            ? null
            : _isHome
                ? null
                : _isMap
                    ? AppBar(
                        title: const Text('Map'),
                      )
                    : null,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(child: SizedBox()),
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _isHome ? Colors.purple : Colors.black45,
                ),
                onPressed: () {
                  _onItemTapped(0);
                },
              ),
              const Expanded(flex: 3, child: SizedBox()),
              IconButton(
                icon: Icon(Icons.map,
                    color: _isMap ? Colors.purple : Colors.black45),
                onPressed: () {
                  _onItemTapped(2);
                },
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _isAdd
            ? null
            : FloatingActionButton(
                onPressed: () {
                  _onItemTapped(1);
                },
                child: const Icon(Icons.add),
              ));
  }
}
