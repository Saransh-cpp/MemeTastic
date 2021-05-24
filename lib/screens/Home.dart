import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String memeUrl = "";
  String memeTitle = "";
  bool isLoading = false;

  Future getURL() async {
    final transport = HttpTransport(
        url: 'https://elastic:m3sZo3yEtcGEq5s3r96ECy0B@memetastic.es.us-west1.gcp.cloud.es.io:9243');
    final client = Client(transport);
    final title = await client.search(
      index: 'dankmemes',
      limit: 50,
      // query: Query.term('url', [
      //   ]),
        source: true,
        trackTotalHits: true
    );

    List memes = [];
    print(title.totalCount);
    for(final iter in title.hits) {
      Map<dynamic, dynamic> currDoc = iter.doc;
      print(currDoc["title"].toString());
      print(currDoc["url"].toString());
      memes.add([currDoc["title"].toString(), currDoc["url"].toString()]);
    }
    var random = new Random();
    int memeNum = random.nextInt(50);

    setState(() {
      memeUrl = memes[memeNum][1];
      isLoading = true;
    });
  }

  @override
  void initState() {
    // getURL();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(Icons.search_rounded),
          )
        ],
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading ? CachedNetworkImage(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.85,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.6,
              imageUrl: memeUrl,
              placeholder: (context, url) {
                print(url);
                return Center(
                  child: Container(
                      height: 40,
                      width: 40,
                      child: SpinKitSquareCircle(
                        color: Colors.purple[500],
                      )),
                );
              },
              errorWidget: (context, url, error) =>
                  SvgPicture.asset('assets/undraw_page_not_found_su7k.svg'),
            ) :
            SvgPicture.asset('assets/undraw_welcome_cats_thqn.svg'),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery
            .of(context)
            .size
            .height / 12,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                icon: Icon(Icons.share_rounded),
                onPressed: () {}
                ),
            IconButton(icon: Icon(Icons.navigate_next), onPressed: () {
              getURL();
            })
          ],
        ),
      ),
    );
  }
}
