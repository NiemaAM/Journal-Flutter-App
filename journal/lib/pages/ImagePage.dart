// ignore_for_file: library_private_types_in_public_api, file_names

import 'dart:io';

import 'package:flutter/material.dart';

class ImagePage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImagePage({Key? key, required this.imageUrls, this.initialIndex = 0})
      : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("image " '${_currentIndex + 1}/${widget.imageUrls.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Center(
              child: Container(
                constraints: const BoxConstraints.expand(),
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 3,
                  child: Image.file(
                    File(widget.imageUrls[index]),
                    width: 150,
                    height: 150,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        'assets/images/image_placeholder.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ),
            onDoubleTap: () {
              if (_pageController.position.pixels == 0) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                );
              } else {
                _pageController.animateToPage(
                  _currentIndex,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                );
              }
            },
          );
        },
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
