// ignore_for_file: depend_on_referenced_packages, file_names
import 'dart:async';
import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Post {
  final int? id;
  final String title;
  final String description;
  List<String>? images;
  List<String>? videos;
  final String locationName;
  final LatLng locationCoords;
  final DateTime date;

  Post({
    this.id,
    this.title = "",
    this.description = "",
    this.images,
    this.videos,
    this.locationName = "",
    required this.locationCoords,
    required this.date,
  }) {
    images ??= [];
    videos ??= [];
  }

// convert a map object to a Post object
  factory Post.fromMap(Map<String, dynamic> json) => Post(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        images: json['images'] != null
            ? json['images'] is Iterable
                ? List<String>.from(json['images'])
                : []
            : [],
        videos: json['videos'] != null
            ? json['videos'] is Iterable
                ? List<String>.from(json['videos'])
                : []
            : [],
        locationName: json['city'],
        locationCoords: LatLng(json['latitude'], json['longitude']),
        date: DateTime.parse(json['date']),
      );

  // convert a Post object to a map object
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'images': images != null ? images!.join(',') : null,
        'videos': videos != null ? videos!.join(',') : null,
        'latitude': locationCoords.latitude,
        'longitude': locationCoords.longitude,
        'city': locationName,
        'date': date.toIso8601String(),
      };
}

class DatabaseHelper {
  static const _databaseName = 'mydatabase.db';
  static const _databaseVersion = 1;

  static const table = 'Post';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnImages = 'images';
  static const columnVideos = 'videos';
  static const columnLatitude = 'latitude';
  static const columnLongitude = 'longitude';
  static const columnCity = 'city';
  static const columnDate = 'date';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // open the database or create a new one if it doesn't exist
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // create the Post table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT,
            $columnDescription TEXT,
            $columnImages TEXT,
            $columnVideos TEXT,
            $columnLatitude REAL,
            $columnLongitude REAL,
            $columnCity TEXT,
            $columnDate TEXT
          )
          ''');
  }

  Future<void> cleanDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = '$dbPath/$_databaseName';

    await deleteDatabase(dbFilePath);
  }

  // insert a post without images or videos
  Future<int> insertPost(Post post) async {
    String? img = post.images?.join(',');
    String? vid = post.videos?.join(',');
    Database db = await database;
    Map<String, dynamic> row = {
      columnTitle: post.title,
      columnDescription: post.description,
      columnImages: img,
      columnVideos: vid,
      columnLatitude: post.locationCoords.latitude,
      columnLongitude: post.locationCoords.longitude,
      columnCity: post.locationName,
      columnDate: post.date.toIso8601String(),
    };
    return await db.insert(table, row);
  }

  Future<int> deletePost(int id) async {
    final db = await database;
    return await db.delete(
      'Post',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// update a post without images or videos
  Future<int> updatePost(Post post, Post newPost) async {
    String img = newPost.images!.join(',');
    String vid = newPost.videos!.join(',');
    Database db = await database;
    Map<String, dynamic> row = {
      columnTitle: newPost.title,
      columnDescription: newPost.description,
      columnImages: img,
      columnVideos: vid,
      columnLatitude: newPost.locationCoords.latitude,
      columnLongitude: newPost.locationCoords.longitude,
      columnCity: newPost.locationName,
      columnDate: newPost.date.toIso8601String(),
    };
    return await db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [post.id],
    );
  }

  Future<List<Post>> getPosts() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query('Post', orderBy: 'id DESC');

    return List.generate(maps.length, (i) {
      return Post(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        images: maps[i]['images'] != null
            ? (maps[i]['images'].toString()).split(',')
            : [],
        videos: maps[i]['videos'] != null
            ? (maps[i]['videos'].toString()).split(',')
            : [],
        locationName: maps[i]['city'],
        locationCoords: LatLng(maps[i]['latitude'], maps[i]['longitude']),
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Stream<List<Post>> getPostsAsStream() async* {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Post');
    yield maps.map((map) => Post.fromMap(map)).toList();
  }
}
