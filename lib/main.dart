import 'package:flutter/material.dart';
import 'package:meme_tastic/screens/Home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MemeTastic',
      home: MyHomePage(url: "", isLoading: false,),
    );
  }
}

