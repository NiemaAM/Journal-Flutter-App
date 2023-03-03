// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:journal/widgets/Post.dart';
import 'package:journal/widgets/PostWidget.dart';

class PostsPage extends StatefulWidget {
  final List<Post> posts;
  const PostsPage({super.key, required this.posts});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late List<Post> _filteredPosts;
  String _searchQuery = '';
  bool _pressed = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    setState(() {
      _filteredPosts = widget.posts;
    });
    super.initState();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredPosts = widget.posts
          .where((post) =>
              post.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _pressed
            ? TextField(
                decoration: const InputDecoration(
                  hintText: 'Search for a post',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _handleSearch,
                controller: _searchController,
              )
            : const Text("My Posts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _pressed = !_pressed;
                _searchController.clear();
                _searchQuery = '';
                _handleSearch('');
              });
            },
          ),
        ],
      ),
      body: widget.posts.isEmpty
          ? const Center(
              child: Text(
              "No post found",
              style: TextStyle(color: Colors.black26),
            ))
          : StreamBuilder<List<Post>>(
              stream: DatabaseHelper.instance.getPostsAsStream(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.purple,
                  ));
                }
                if (_searchController.text.isEmpty) {
                  return ListView.builder(
                    itemCount: widget.posts.length,
                    itemBuilder: (context, index) {
                      return PostWidget(post: widget.posts[index]);
                    },
                  );
                } else {
                  // Build your widget with the updated posts list here
                  return ListView.builder(
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      return PostWidget(post: _filteredPosts[index]);
                    },
                  );
                }
              },
            ),
    );
  }
}
