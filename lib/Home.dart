import 'dart:convert';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'All_Radio_Station.dart';
import 'Favorite.dart';
import 'Helper/Constant.dart';
import 'Helper/Model.dart';
import 'SubCategory.dart';
import 'main.dart';

///category list
List<Model> catList = [];

///current slider position
int _curSlider = 0;

///slider list
List<Model> slider_list = [];

///slider image list
List slider_image = [];

///favorite list size
int favSize = 0;

///is category loading
bool catloading = true;

///is error exist or not
bool errorExist = false;

///home class
class Home extends StatefulWidget {
  VoidCallback _play, _pause, _next, _previous;

  ///constructor
  Home(
      {VoidCallback play,
      VoidCallback pause,
      VoidCallback next,
      VoidCallback previous})
      : _play = play,
        _pause = pause,
        _next = next,
        _previous = previous;

  _Home_State createState() => _Home_State();
}

class _Home_State extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    useMobileLayout = shortestSide < 600;

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(bottom: 200.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CarouselWithIndicator(
                          play: widget._play,
                        ),
                        getLabel('Category'),
                        getCat(),
                        getLabel('Latest'),
                        getLatest(),
                        getFavorite(),
                      ],
                    ),
                  ),
                ),
              ),
              AdmobBanner(
                adUnitId: getBannerAdUnitId(),
                adSize: AdmobBannerSize.BANNER,
              ),
            ],
          )),
    );
  }

  Future<void> getSlider() async {
    var data = {'access_key': '6808'};
    var response = await http.post('$slider_api', body: data);
    var getdata = json.decode(response.body);

    if (!mounted) return null;
    setState(() {
      var error = getdata['error'].toString();

      if (error == 'false') {
        var data1 = (getdata['data']);

        slider_list = (data1 as List)
            .map((data) => Model.fromJson(data as Map<String, dynamic>))
            .toList();

        // slider_list.forEach((f) => slider_image.add(f.image));

        for (var f in slider_list) {
          slider_image.add(f.image);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSlider();
    getCategory();
  }

  Widget getFavorite() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.none ||
              projectSnap.data == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            favSize = int.parse(projectSnap.data.length.toString());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                favSize == 0
                    ? Container(
                        height: 0,
                      )
                    : getLabel('Favorites'),
                Container(
                    height: favSize == 0 ? 10 : 150,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        itemCount: int.parse(
                                    projectSnap.data.length.toString()) >
                                0
                            ? int.parse(projectSnap.data.length.toString()) >=
                                    10
                                ? 10
                                : int.parse(projectSnap.data.length.toString())
                            : 0,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  '${projectSnap.data[i].image}')),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                offset: Offset(2, 2))
                                          ],
                                        ))),
                                Container(
                                  // color: primary.withOpacity(0.2),
                                  width: 100,
                                  child: Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Text(
                                      '${projectSnap.data[i].name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ],
                            ),
                            onTap: () {
                              curPos = i;
                              curPlayList = projectSnap.data as List<Model>;
                              url =
                                  projectSnap.data[curPos].radio_url.toString();

                              //  print("current url**$url");

                              position = null;
                              duration = null;

                              if (url.isNotEmpty) {
                                widget._play();
                              }
                            },
                          );
                        }))
              ],
            );
          }
        },
        future: db.getAllFav(),
      ),
    );
  }

  Future getCategory() async {
    var data = {
      'access_key': '6808',
    };
    var response = await http.post(cat_api, body: data);

    print('responce*****cat${response.body.toString()}');

    var getData = json.decode(response.body);

    var error = getData['error'].toString();

    setState(() {
      catloading = false;
      if (error == 'false') {
        var data1 = (getData['data']);
        // catList = (data as List).map((Map<String, dynamic>) => Model.fromJson(data)).toList();

        catList = (data1 as List)
            .map((data) => Model.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        errorExist = true;
      }
    });
  }

  final Style = TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'Nunito',
      fontSize: 20,
      color: Colors.white54);

  Widget getLabel(String cls) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              cls,
              style: Style,
            ),
            GestureDetector(
              child: Text(
                'See more',
                style: Theme.of(context).textTheme.caption.copyWith(
                    color: Color(0xff0ACF83),
                    decoration: TextDecoration.underline,
                    fontFamily: 'Nunito'),
              ),
              onTap: () {
                if (cls == 'Category') {
                  tabController.animateTo(1);
                } else if (cls == 'Latest') {
                  tabController.animateTo(2);
                } else if (cls == 'Favorites') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Favorite(
                            play: widget._play,
                            pause: widget._pause,
                            next: widget._next,
                            previous: widget._previous),
                      ));
                }
              },
            ),
          ],
        ));
  }

  Widget getLatest() {
    var length = int.parse(radioList.length.toString());

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
            height: 260,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: length > 0
                    ? length > 10
                        ? 10
                        : length
                    : 0,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    child: Column(
                      children: <Widget>[
                       Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Card(shadowColor: Colors.black,
                              borderOnForeground: true,
                              elevation: 40,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.black54,
                              child: Container(
                                width: 170,
                                height: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '${radioList[i].image}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        Container(
                          // color: primary.withOpacity(0.2),
                          width: 100,
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              '${radioList[i].name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: 'Nunito',color: Colors.white,fontWeight: FontWeight.w700,),
                            ),
                          ),
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                    onTap: () {
                      curPos = i;
                      curPlayList = radioList;
                      url = radioList[curPos].radio_url;

                      position = null;
                      duration = null;
                      widget._play();
                    },
                  );
                })));
  }

  Widget getCat() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
            height: 300,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: catList.isNotEmpty
                    ? catList.length > 10
                        ? 10
                        : catList.length
                    : 0,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 50, 10, 10),
                          child: Card(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 40,
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width / 1.1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 5.0, 10, 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            '${catList[i].cat_name}',
                                            maxLines: 1,
                                            style: Style,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -30,
                          bottom: 80,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              0,
                              0,
                              0,
                            ),
                            child: Card(
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 40,
                              child: Container(
                                height: 100,
                                width: 130,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      '${catList[i].image}',
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubCategory(
                                  play: widget._play,
                                  pause: widget._pause,
                                  next: widget._next,
                                  previous: widget._previous,
                                  cityId: "",
                                  catId: catList[i].id)));
                    },
                  );
                })));
  }
}

///coarousel slider
class CarouselWithIndicator extends StatefulWidget {
  final VoidCallback _play;

  ///constructor
  CarouselWithIndicator({VoidCallback play}) : _play = play;

  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  @override
  Widget build(BuildContext context) {
    return slider_list.isEmpty
        ? Container(
            padding: EdgeInsets.all(10),
            child: Center(child: CircularProgressIndicator()),
            height: 200,
          )
        : Stack(children: [
            CarouselSlider(
              items: getSlider(),
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              aspectRatio: useMobileLayout ? 2.0 : 3.0,
              onPageChanged: (index) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  if (index < slider_list.length) {
                    _curSlider = index;
                  }
                });
              },
            ),
            Positioned(
                bottom: 5,
                right: 45,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 5.0,
                        maxWidth: 200.0,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black45),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            slider_list[_curSlider].name,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
            Positioned(
                bottom: 5,
                left: 60,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: map<Widget>(
                    slider_list,
                    (index, url) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _curSlider == index
                                ? Color.fromRGBO(0, 0, 0, 0.9)
                                : Color.fromRGBO(0, 0, 0, 0.4)),
                      );
                    },
                  ),
                )),
          ]);
  }

  List<Widget> getSlider() {
    return map<Widget>(
      slider_image,
      (index, i) {
        return GestureDetector(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: FadeInImage(
                image: NetworkImage(i.toString()),
                placeholder: AssetImage('assets/image/placeholder.png'),
                width: 1000.0,
                height: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
          ),
          onTap: () async {
            // .print("get pos**$url**$index***${slider_list.length}");

            if (index < int.parse(slider_list.length.toString()) != null) {
              curPos = int.parse(index.toString());

              curPlayList = slider_list;
              url = slider_list[curPos].radio_url;
              //print("get pos**url$url");
              position = null;
              duration = null;
              widget._play();
            }
          },
        );
      },
    ).toList();
  }
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    //print("string**$i***${list[i]}");

    result.add(handler(i, list[i]));
  }

  return result;
}
