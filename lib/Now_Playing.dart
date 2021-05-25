import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

import 'Helper/Constant.dart';
import 'main.dart';

final _text = TextEditingController();
bool _validate = false;

///now playing inside class
class Now_Playing extends StatefulWidget {
  final VoidCallback _play, _pause, _next, _prev, _refresh;

  ///constructor
  Now_Playing(
      {VoidCallback play,
      VoidCallback pause,
      VoidCallback next,
      VoidCallback prev,
      VoidCallback refresh})
      : _play = play,
        _pause = pause,
        _next = next,
        _prev = prev,
        _refresh = refresh;

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<Now_Playing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: curPlayList.isEmpty ? Container() : getContent());
  }

  getContent() {
    return


        Stack(fit: StackFit.passthrough, children: [

          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color(0xff1B1D32),
          ),
          Container(
            height: MediaQuery.of(context).size.height/4,
            color: Colors.teal,
          ),
          Padding(
            padding: const EdgeInsets.only(top:30.0),
            child: Align(alignment: Alignment.topCenter,
              child: Card(color: Colors.black54,elevation: 40,
                child: Container(
                  height: 230,width: 230,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FadeInImage(
                        placeholder: AssetImage('assets/image/placeholder.png'),
                        image: NetworkImage(curPlayList[curPos].image),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )),
                ),),
            ),
          ),
           Padding(
             padding: const EdgeInsets.only(bottom:40.0),
             child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 58.0),
                  child: Text(
                      curPlayList[curPos].name,
                      style: Theme.of(context).textTheme.title,
                      textAlign: TextAlign.center,
                    ),
                ),
              ),
           ),
          Padding(
            padding: const EdgeInsets.only(top:70.0),
            child: Align(
            alignment: Alignment.center,
              child:  Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                child: ListView(

                  children: [ Text(
            curPlayList[curPos].description,maxLines: 5,
            style: Theme.of(context)
                    .textTheme
                    .subtitle
                    .copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
        ),]
                ),
              ),

              ),
          ),
          getMiddleButton(),
          getMediaButton()
    ]);
  }

  getMiddleButton() {
    return Padding(
      padding: const EdgeInsets.only(top:158.0),
      child: Align(
       alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.share,size: 25,),
                onPressed: () {
                  if (Platform.isAndroid) {
                    Share.share('I am listening to-\n'
                        '${curPlayList[curPos].name}\n'
                        '$appname\n'
                        'https://play.google.com/store/apps/details?id=$androidPackage&hl=en');
                  } else {
                    Share.share('I am listening to-\n'
                        '${curPlayList[curPos].name}\n'
                        '$appname\n'
                        '$iosPackage');
                  }
                },
                color: Colors.white,
              ),
              FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data == true
                        ? IconButton(
                            icon: Icon(
                              Icons.favorite,
                              size: 25,
                              color: primary,
                            ),
                            onPressed: () async {
                              await db.removeFav(curPlayList[curPos].id);
                              if (!mounted) {
                                return;
                              }
                              setState(() {});
                              widget._refresh();
                            })
                        : IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              size: 25,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await db.setFav(
                                  curPlayList[curPos].id,
                                  curPlayList[curPos].name,
                                  curPlayList[curPos].description,
                                  curPlayList[curPos].image,
                                  curPlayList[curPos].radio_url);
                              setState(() {});
                              widget._refresh();
                            });
                  } else {
                    return Container();
                  }
                },
                future: db.getFav(curPlayList[curPos].id),
              ),
              IconButton(
                icon: Icon(Icons.queue_music,size: 25,),
                onPressed: () {
                  panelController.close();
                },
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(Icons.report,size: 25,),
                onPressed: () {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return ReportDialog();
                        });
                  });
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getMediaButton() {
    return Positioned(
      top: 380,
      width: 350,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.fast_rewind),
                      iconSize: 35,
                      onPressed: widget._prev,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: Icon(Icons.fast_forward),
                      iconSize: 35,
                      onPressed: widget._next,
                      color: Colors.white,
                    ),
                  ],
                )),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(

                    child: (Platform.isIOS)
                          ? (isPlaying == true &&
                                  playerState == PlayerState.playing)
                              ? IconButton(
                        ///pause
                                  icon: Image.asset(
                                       'assets/image/pause.png'),
                                  iconSize: 80,
                                 // color: Colors.black54,
                                  onPressed: widget._pause)
                              : IconButton(
                        ///play
                                  icon: Image.asset(
                                      'assets/image/play.png'),
                                  iconSize: 80,
                                //  color: Colors.black54,
                                  onPressed: widget._play)
                          : (duration == null &&
                                  playerState != PlayerState.stopped)
                              ? Container(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white54
                                      )),
                                )
                              : IconButton(
                        ///pause
                        ///play
                                  icon: Center(
                                    child: Image.asset(isPlaying == true
                                        ? 'assets/image/pause.png'
                                        :'assets/image/play.png'),
                                  ),
                                  iconSize: 80,

                                  onPressed: isPlaying == true
                                      ? widget._pause
                                      : widget._play,
                                ),
                    ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

///report dialog
class ReportDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<ReportDialog> {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Text(
          'Report',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: primary, fontSize: 20),
        ),
      ),
      content: Column(
        children: <Widget>[
          Text('Your issue with this radio will be checked.'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: _text,
                decoration: InputDecoration(
                    hintText: 'Write your issue',
                    errorText: _validate ? 'Value Can\'t Be Empty' : null,
                    border: OutlineInputBorder()),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              _validate = false;
              Navigator.pop(context, 'Cancel');
            }),
        CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              'SEND',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              if (!mounted) {
                return;
              }
              setState(() {
                _text.text.isEmpty ? _validate = true : _validate = false;
                if (_validate == false) {
                  radioReport(curPlayList[curPos].id, _text.text);
                  Navigator.pop(context, 'Cancel');
                }
              });
            }),
      ],
    );
  }

  Future<void> radioReport(String station_id, String msg) async {
    var data = {
      'access_key': '6808',
      'radio_station_id': station_id.toString(),
      'message': msg
    };
    var response = await http.post(report_api, body: data);

    // print("responce***getting**${response.body.toString()}");

    var getdata = json.decode(response.body);
    total = int.parse(getdata['total'].toString());
    //String error = getdata["error"].toString();

    //msg1 = getdata['message'].toString();
  }
}
