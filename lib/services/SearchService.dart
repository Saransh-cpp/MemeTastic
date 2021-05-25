
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meme_tastic/screens/Home.dart';


class SearchService extends SearchDelegate {

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        color: Colors.white
      ),
      primaryColor: Colors.white,
      primaryIconTheme: IconThemeData(
        color: Colors.black
      ),
      // primaryColorBrightness: Brightness.dark,
      primaryTextTheme: theme.primaryTextTheme,
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          FocusScope.of(context).unfocus();
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        future: search(query.toLowerCase()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return SvgPicture.asset('assets/undraw_searching_p5ux.svg');
          }
          return displayMemeTile(snapshot.data, context);
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: search(query.toLowerCase()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData || query.isEmpty) {
          print("yes");
          return SvgPicture.asset('assets/undraw_searching_p5ux.svg');
        }

        return displayMemeTile(snapshot.data, context);
      },
    );
  }

  Widget displayMemeTile(List memes, BuildContext context) {
    return ListView.builder(
        itemCount: memes.length,
        itemBuilder: (BuildContext _, int index)
    {
      return ListTile(
        onTap: () {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MyHomePage(url: memes[index][1], isLoading: true,)));
        },
        title: Text(memes[index][0]),
      );
    });
  }

  Future search(queryReceived) async {
    final transport = HttpTransport(url: 'https://elastic:m3sZo3yEtcGEq5s3r96ECy0B@memetastic.es.us-west1.gcp.cloud.es.io:9243');
    final client = Client(transport);
    List memes = [];

    final result = await client.search(
        index: 'dankmemes',
        limit: 100,
        type: '_doc',
        query: Query.term('title', ['$queryReceived']),
        source: true
    );

    for(final meme in result.hits){
      Map<dynamic, dynamic> currentMeme = meme.doc;
      memes.add([currentMeme['title'].toString(), currentMeme['url'].toString()]);
    }

    await transport.close();

    if(result.totalCount <= 0 )
      return null;
    else
      return memes;
  }
}
