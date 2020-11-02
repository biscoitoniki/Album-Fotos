import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Photo{
  final int id;
  final String title;
  final String thumbnail;
  final String url;

  Photo({this.id,this.title,this.thumbnail, this.url});

  factory Photo.fromJson(Map<String, dynamic> json){
    return Photo(
      id: json['id'] as int,
      title: json['title'] as String,
      thumbnail:  json['thumbnailUrl'] as String,
      url: json['url'] as String
      );
  }
}

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response =
    await client.get('https://jsonplaceholder.typicode.com/photos');

  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String responsebody){
  final parsed = jsonDecode(responsebody).cast<Map<String, dynamic>>();
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class PhotosList extends StatelessWidget {
  final List<Photo> photos;

  PhotosList({Key key, this.photos}) : super(key:key);
//Image.network(photos[index].thumbnail)
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), 
      itemBuilder: (context, index) {
        return FlatButton(
            child: Image.network(photos[index].thumbnail),
              onPressed: () 
                {Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => DetailPhoto(
                    foto: photos[index],
                  )
              )
            );
          }     
        );
      },
    );
  }

}

class DetailPhoto extends StatelessWidget {
  final Photo foto;

  DetailPhoto({Key key, @required this.foto}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Image.network(foto.url)
        )
      )
    );
  }
}


class Home extends StatelessWidget{
  final String title;
  Home({Key key, this.title}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(title),),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot){
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData ? PhotosList(photos: snapshot.data,) : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  
}

void main()=> runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Isolate Demo';

    return MaterialApp(title: appTitle, home: Home(title: appTitle,),);
  }

}