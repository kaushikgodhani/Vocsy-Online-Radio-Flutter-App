import 'dart:convert';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:radio_app/Helper/City_Model.dart';

import 'Category.dart';
import 'Helper/Constant.dart';
import 'Helper/Model.dart';
import 'SubCategory.dart';


///for managing cat, sub-cat visibility in single layout
bool cityVisible = true, radioVisible = false;
List<City_Model> cityList = [];

///category sub-cat claass
class City extends StatefulWidget {
  final VoidCallback _play ,_next, _previous, _pause;

  ///constructor
  City( {VoidCallback play,
    VoidCallback refresh,
    VoidCallback next,
    VoidCallback previous,
    VoidCallback pause})
      : _play = play,
        _next = next,
        _previous = previous,
        _pause = pause;

  _Player_State createState() => _Player_State();
}

// ignore: camel_case_types
class _Player_State extends State<City>
    with AutomaticKeepAliveClientMixin<City> {
 // ScrollController _controller;
  List<Model> _catRadioList = [];

  bool _errorCityExist = false;
  bool _cityLoading = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(body: cityLayout());
  }

  Widget cityLayout() {
    return _cityLoading
        ? getLoader()
        : _errorCityExist ? getErrorMsg() : getCityGrid();
  }


  @override
  void initState() {
    super.initState();

    getCity();
  }

  @override
  bool get wantKeepAlive => true;

  Widget listItem(int index) {
    return Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 4.0,
        child: IntrinsicHeight(
            child: InkWell(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  VerticalDivider(
                    color: Color(0xff0ACF83),
                    thickness: 2,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        cityList[index].cityName,
                        style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Nunito'),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              )),
          onTap: () {
            if (!mounted) return;


            catVisible = true;

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SubCategory(
                        play: widget._play,
                        pause: widget._pause,
                        next: widget._next,
                        previous: widget._previous,
                        cityId:cityList[index].id,
                        catId: "")));


          },
        )));
  }

  getLoader() {
    return Container(
        height: 200, child: Center(child: CircularProgressIndicator()));
  }

  getErrorMsg() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 20),
        child: Text(
          'No Category Available..!!',
          textAlign: TextAlign.center,
        ));
  }

  getCityGrid() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 200.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cityList.length,
                 // controller: _controller,
                  itemBuilder: (context, index) {
                    return listItem(index);
                  },
                ),
              ),
            ),
            //  Spacer(),
            AdmobBanner(
              adUnitId: getBannerAdUnitId(),
              adSize: AdmobBannerSize.BANNER,
            ),
          ],
        ));
  }

  Future getCity() async {
    var data = {
      'access_key': '6808',
    };
    var response = await http.post(city_api, body: data);

    print('get responce*****city**${response.body.toString()}');
    var getData = json.decode(response.body);

    var error = getData['error'].toString();

    setState(() {
      _cityLoading = false;
      if (error == 'false') {
        var data1 = (getData['data']);

        cityList = (data1 as List)
            .map((data) => City_Model.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        _errorCityExist = true;
      }
    });
  }

/*  Future getCategory(String id) async {
    var data = {'access_key': '6808', 'city_id': id};
    var response = await http.post(city_by_id, body: data);

    print('responce*****cat${response.body.toString()}');

    var getData = json.decode(response.body);

    var error = getData['error'].toString();

    setState(() {
      _catLoading = false;
      if (error == 'false') {
        var data1 = (getData['data']);
        // catList = (data as List).map((Map<String, dynamic>) => Model.fromJson(data)).toList();

        catList = (data1 as List)
            .map((data) => Model.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        _errorCat = true;
      }
    });
  }*/
}
