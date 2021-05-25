import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meme_tastic/services/SearchService.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'package:wc_flutter_share/wc_flutter_share.dart';

class MyHomePage extends StatefulWidget {

  String url;
  bool isLoading;

  MyHomePage({Key key, this.url, this.isLoading}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // String memeUrl = "";
  String memeTitle = "";
  // bool isLoading = false;

  Future getURL() async {
    final transport = HttpTransport(
        url: 'https://elastic:m3sZo3yEtcGEq5s3r96ECy0B@memetastic.es.us-west1.gcp.cloud.es.io:9243');
    final client = Client(transport);
    final title = await client.search(
      index: 'dankmemes',
      limit: 50,
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
      widget.url = memes[memeNum][1];
      widget.isLoading = true;
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
            child: IconButton(icon: Icon(Icons.search_rounded), onPressed: () {searchScreen();},)
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
            widget.isLoading ? CachedNetworkImage(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.85,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.6,
              imageUrl: widget.url,
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
                onPressed: () async {
                  if (widget.url == "") {
                    Fluttertoast.showToast(
                      msg: "Oops :(, please load a meme first",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                    );
                  } else {
                    if (widget.url.substring(widget.url.length - 3) == 'png' || widget.url.substring(widget.url.length - 3) == 'jpg') {
                      http.Response response = await http.get(
                        Uri.parse(widget.url),);
                      await
                      WcFlutterShare.share(
                        sharePopupTitle: 'Share with?',
                        subject: 'MemeTastic',
                        text: 'Hey, checkout this meme from reddit',
                        fileName: 'meme.png',
                        mimeType: 'image/png',
                        bytesOfFile: response.bodyBytes,
                      );
                    } else {
                      Share.share("Hey, checkout this meme from reddit - ${widget.url}");
                    }
                  }
                }
                ),
            IconButton(icon: Icon(Icons.navigate_next), onPressed: () {
              getURL();
            })
          ],
        ),
      ),
    );

  }
  Future<void> searchScreen() async {
    await showSearch(
      context: context,
      delegate: SearchService(),
      query: "",
    );
  }
}
