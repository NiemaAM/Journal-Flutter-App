// ignore_for_file: file_names, depend_on_referenced_packages, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:journal/pages/PostDetailsPage.dart';

import 'Post.dart';
import 'dart:core';
import 'package:intl/intl.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> mediaWidgets = [];
    bool isLocate = true;
    void _isLocation() {
      if (post.locationCoords.latitude == 0.0 &&
          post.locationCoords.longitude == 0.0) {
        isLocate = false;
      } else {
        isLocate = true;
      }
    }

    _isLocation();
    // Add images
    for (int i = 0; i < post.images!.length && i < 4; i++) {
      mediaWidgets.add(
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(2.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: File(post.images![i]).path.isEmpty
                  ? null
                  : File(post.images![i]).path.endsWith("/")
                      ? null
                      : Image.file(
                          File(post.images![i]),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
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
      );
    }
/* 
    // Add video placeholders
    if (post.videos!.isNotEmpty) {
      int remaining = post.videos!.length - (4 - post.images!.length);
      mediaWidgets.add(
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(2.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/image_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                  if (remaining > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      left: 0,
                      child: Center(
                        child: Text(
                          '+$remaining',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
 */
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(post: post),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: isLocate
                        ? const Color.fromARGB(255, 115, 73, 116)
                        : Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    post.locationName,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14.0,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(post.date),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              if (post.description.length > 50)
                Text(
                  '${post.description.substring(0, 50).replaceAll('\n', ' ')}${post.description.length > 50 ? '...' : ''}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              if (post.description.length < 50)
                Text(
                  post.description,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              const SizedBox(height: 8.0),
              Row(
                children: mediaWidgets,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
