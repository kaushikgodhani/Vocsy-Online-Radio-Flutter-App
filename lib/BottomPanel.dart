import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Helper/Constant.dart';

///now playing bottom panel
class BottomPanel extends StatelessWidget {
  final VoidCallback _play, _pause;

  ///constructor
  BottomPanel({VoidCallback play, VoidCallback pause})
      : _play = play,
        _pause = pause;

  @override
  Widget build(BuildContext context) {
    return getBottomPanelLayout();
  }

  ///bottom panel layout
  Widget getBottomPanelLayout() {
    return Container(
        // Add box decoration
        decoration: getBackGradient(),
        child: curPlayList.isNotEmpty ? getRowLayout() : Container());
  }

  getBackGradient() {
    return BoxDecoration(
      // Box decoration takes a gradient
      gradient: LinearGradient(
        // Where the linear gradient begins and ends
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        // Add one stop for each color. Stops should increase from 0 to 1
        stops: [0.6, 0.9],
        colors: [Color(0xff1D1F34), Color(0xff2E6ED8)],
      ),
    );
  }

  getRowLayout() {
    print('current status****$duration****$playerState***$isPlaying');

    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 20, left: 10),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: FadeInImage(
                      placeholder: AssetImage('assets/image/placeholder.png'),
                      image: NetworkImage(curPlayList[curPos].image),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        curPlayList[curPos].name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    MarqueeWidget(
                        direction: Axis.horizontal,
                        child: Text(
                          curPlayList[curPos].description,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (curPlayList[curPos].radio_url == null) {
                return;
              }

              if (isPlaying == true) {
                _pause();
              } else {
                _play();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: (Platform.isIOS)
                        ? (isPlaying == true &&
                                playerState == PlayerState.playing)
                            ? Image.asset(
                                'assets/image/pause.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/image/play.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                        : (duration == null &&
                                playerState != PlayerState.stopped)
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : isPlaying == true
                                ? Image.asset(
                                    'assets/image/pause.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/image/play.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )),
              ],
            ),
          ),
        )
      ],
    );
  }
}

///current playing song name marquee
class MarqueeWidget extends StatefulWidget {
  final Widget _child;
  final Axis _direction;
  final Duration _animationDuration = const Duration(milliseconds: 3000),
      _backDuration = const Duration(milliseconds: 800),
      _pauseDuration = const Duration(milliseconds: 800);

  ///constructor
  MarqueeWidget({
    Widget child,
    Axis direction,
  })  : _child = child,
        _direction = direction;

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    scroll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget._child,
      scrollDirection: widget._direction,
      controller: _scrollController,
    );
  }

  void scroll() async {
    //while (true) {
    if (!mounted) {
      return;
    }
    await Future.delayed(widget._pauseDuration);
    await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: widget._animationDuration,
        curve: Curves.easeIn);

    await Future.delayed(widget._pauseDuration);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(0.0,
            duration: widget._backDuration, curve: Curves.easeOut);
      }
    });
    //}
  }
}
