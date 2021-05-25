import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'Helper/Constant.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

///splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ));
  }

  @override
  void initState() {
    super.initState();
    getcityMode();

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/splash.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(bottom:38.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:CrossAxisAlignment.end ,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  elevation: 40,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/image/logo.jpg',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getcityMode() async {
    var data = {'access_key': '6808'};
    var response = await http.post(city_mode, body: data);

    print("responce****city mode**${response.body.toString()}");

    var getdata = json.decode(response.body);

    var error = getdata['error'].toString();
    if (!mounted) return null;

    if (error == 'false') {
      var city = getdata['data'];

      if (city == "1") {
        cityMode = true;
      } else {
        cityMode = false;
      }
    } else {
      cityMode = false;
    }
  }
}
