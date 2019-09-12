import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:promethean_2k19/data_models/event_model.dart';
import 'package:promethean_2k19/newRegistrationScreen.dart';
import 'package:promethean_2k19/screens/registrationDiaolog.dart';
import 'package:promethean_2k19/utils/urls.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationScreen extends StatefulWidget {
  final String organizingDepartment;
  final String eventName;

  const RegistrationScreen(
      {Key key, @required this.eventName, @required this.organizingDepartment})
      : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextStyle lableStyle = new TextStyle(
      fontSize: 20.0,
      letterSpacing: 0.5,
      color: Colors.black,
      fontWeight: FontWeight.bold);
  final TextStyle contentStyle =
      new TextStyle(fontSize: 15.0, letterSpacing: 0.7, color: Colors.black87);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Event event;
  Future _future;
  String _radiogroupValue = "";
  List<Widget> radioList = [];
  String rbvalue = "";
  Map<String, dynamic> temp = {
    'name': null,
    'email': null,
    'phonenum': null,
    'eventName': null,
    'eventType': null
  };
  String getTodayDate() {
    var now = new DateTime.now();
    return now.day.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.year.toString();
  }

  Future<Null> _getEvent({String eventName, String organizingDept}) async {
    print(eventName);
    // print("getting $eventName form $eventType");
    print(Urls.getEvent + "$organizingDept/$eventName.json");
    await http
        .get(Urls.getEvent + "$organizingDept/$eventName.json")
        .then((http.Response response) {
      print("entered Here");
      print(json.decode(response.body));
      Map<String, dynamic> fetchedData;
      fetchedData = json.decode(response.body);
      print(fetchedData);
      fetchedData.forEach((String uniqueId, dynamic value) {
        event = new Event(
            eventName: value['eventName'],
            organizedBy: value['organizedBy'],
            eventDesc: value['eventDesc'],
            eventRules: value['eventRules'],
            eventType: value['eventType'],
            eventDetails: value['eventDetails'],
            imageUrl: value['imageurl'],
            id: value['id'],
            cordinators: value['cordinators'],
            // eventRegsFee: value['eventRegsFee'],
            individualFee: value['individualFee'],
            organizerMailId: value['organizerMailId'],
            teamFee: value['teamFee'],
            organizedDept: value['organizedDept']);
        print("this is organised by ${event.eventType}");
        print('$fetchedData');
      });
    }); //get
  }

  @override
  void initState() {
    _future = _getEvent(
        eventName: widget.eventName,
        organizingDept: widget.organizingDepartment);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        elevation: 3.0,
        title: new Text(
          "Registration",
          style: new TextStyle(
            color: Colors.black,
            fontFamily: 'bebas-neue',
            fontSize: 25.0,
          ),
        ),
      ),
     
      body: FutureBuilder<Event>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                    color: Colors.grey.withOpacity(0.5),
                    child: CupertinoAlertDialog(
                      content: SizedBox(
                        height: 45.0,
                        child: Center(
                          child: Row(
                            children: <Widget>[
                              CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                              Expanded(
                                child: Text(
                                  "Loading..",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );

              case ConnectionState.done:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  Future.delayed(const Duration(milliseconds: 1000)).then((_) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "No Internet Connection.",
                        style: TextStyle(fontSize: 13.0),
                      ),
                      action: SnackBarAction(
                        textColor: Colors.pink,
                        label: 'Ok',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ));
                  });
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Please check your device network connection !!",
                          style: TextStyle(
                              fontWeight: FontWeight.w300, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return  ScreenRegistration(event: event,);
            }
            // this doesnt come accross
            return Container();
          }
          // buildregistartionBody(targetPadding, deviceheight, deviceWidth, _submitForm)

          ),
    );
  }


}
