
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/elastic_client.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';


class SearchService extends SearchDelegate {

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          // await searchElasticServer(query);
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
          return displayMemeTile(snapshot.data);
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

        if (snapshot.data == false) {
          return SvgPicture.asset('assets/undraw_searching_p5ux.svg');
        }
        return displayMemeTile(snapshot.data);
      },
    );
  }

  Widget displayMemeTile(List memes) {
    return ListView.builder(
        itemCount: memes.length,
        itemBuilder: (BuildContext _, int index)
    {
      return ListTile(
        leading: CachedNetworkImage(
          imageUrl: memes[index][1],
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
        ),
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
      return false;
    else
      return memes;
  }
}
