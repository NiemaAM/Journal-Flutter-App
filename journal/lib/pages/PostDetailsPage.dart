// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:journal/pages/UdatePage.dart';

import '../widgets/Post.dart';
import 'ImagePage.dart';
import 'package:intl/intl.dart';

import 'PostMap.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  void _deletePost(int id) async {
    await DatabaseHelper.instance.deletePost(id);
  }

  bool _location = false;
  void _isLocation() {
    if (widget.post.locationCoords.latitude == 0.0 &&
        widget.post.locationCoords.longitude == 0.0) {
      setState(() {
        _location = false;
      });
    } else {
      setState(() {
        _location = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLocation();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "update",
                child: Text("Update post"),
              ),
              const PopupMenuItem(
                value: "remove",
                child: Text("Remove post"),
              ),
            ],
            onSelected: (value) {
              if (value == "remove") {
                // Code to remove post goes here
                _deletePost(widget.post.id!);
                Navigator.of(context).pop();
              }
              if (value == "update") {
                // Code to remove post goes here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdatePage(post: widget.post),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 8, right: 8, bottom: 14),
                  child: Text(
                    widget.post.description,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (widget.post.images!.isNotEmpty)
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      widget.post.images!.length,
                      (index) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImagePage(
                                imageUrls: widget.post.images!,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: File(widget.post.images![index]).path.isEmpty
                            ? null
                            : File(widget.post.images![index])
                                    .path
                                    .endsWith("/")
                                ? null
                                : Image.file(
                                    File(widget.post.images![index]),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
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
                /* if (widget.post.videos!.isNotEmpty)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.post.videos!.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[300],
                          ),
                          child: Center(
                            child: Text(
                              'Video ${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ), */
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16, left: 18, right: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.post.locationName,
                  style: const TextStyle(fontSize: 16),
                ),
                const Expanded(child: SizedBox()),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(widget.post.date),
                  style: const TextStyle(fontSize: 10),
                ),
                const Expanded(child: SizedBox()),
                _location
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostMap(
                                post: widget.post,
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.location_on,
                          size: 32,
                        ))
                    : const SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
