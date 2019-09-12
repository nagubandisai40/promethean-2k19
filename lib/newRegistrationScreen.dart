import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:promethean_2k19/common/messageBox.dart';
import 'package:promethean_2k19/data_models/event_model.dart';
// import 'package:promethean_2k19/screens/registeredEvents.dart';
import 'package:promethean_2k19/screens/registrationDiaolog.dart';
// import 'package:promethean_2k19/utils/urls.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;

class ScreenRegistration extends StatefulWidget {
  final Event event;
  final GlobalKey<ScaffoldState> scaffoldState;

  const ScreenRegistration({Key key, @required this.event, this.scaffoldState})
      : super(key: key);
  @override
  _ScreenRegistrationState createState() => _ScreenRegistrationState();
}

class _ScreenRegistrationState extends State<ScreenRegistration> {
  TextStyle textStyle =
      TextStyle(fontFamily: 'QuickSand', fontSize: 15.0, color: Colors.black);
  String sampleText =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum";

  eventDescriptionScreen() {
    TextStyle hintStyle =
        TextStyle(fontFamily: 'QuickSand', fontSize: 15.0, color: Colors.black);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new PopScreen(
            scafflodcontext: context,
            scaffoldKey: widget.scaffoldState,
            event: widget.event,
            hintStyle: hintStyle,
          );
        });
  }

  List<Widget> _getChips() {
    print("The Event Type is ${widget.event.eventType}");
    if (widget.event.eventType.toLowerCase() == "individual") {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Chip(
            backgroundColor: Colors.green,
            label: Text("Individual: ₹${widget.event.individualFee}",
                style: textStyle.copyWith(color: Colors.white)),
          ),
        ),
      ];
    } else if (widget.event.eventType.toLowerCase() == "team") {
      return [
        Chip(
          label: Text(
            "Team: ₹${widget.event.teamFee}",
            style: textStyle.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.orange.withOpacity(0.7),
        ),
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Chip(
            backgroundColor: Colors.green,
            label: Text("Individual: ₹${widget.event.individualFee}",
                style: textStyle.copyWith(color: Colors.white)),
          ),
        ),
        Chip(
          label: Text(
            "Team: ₹${widget.event.teamFee}",
            style: textStyle.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.orange.withOpacity(0.7),
        ),
      ];
    }
  }

  String _getBranchLong(String str)
  {
    if(str.toLowerCase()=="bme")
    {
      return "Biomedical Engineering";
    }else if(str.toLowerCase()=="chem")
    {
      return "Chemical Engineering";
    }else if(str.toLowerCase()=="civil")
    {
      return "Civil Engineering";
    }
    else if(str.toLowerCase()=="cse")
    {
      return "Computer Science and Engineering";
    }else if(str.toLowerCase()=="eee")
    {
      return "Electrical and Electronic Engineering";
    }else if(str.toLowerCase()=="ece"){
      return "Electronics and Communication Engineering";
    }else if(str.toLowerCase()=="it"){
      return "Information Technology";
    }else if(str.toLowerCase()=="mech")
    {
      return "Mechanical Engineering";
    }else if(str.toLowerCase()=="phe"){
      return "Pharmaceutical Engineering";
    }else{
      return str;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ConstrainedBox(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                color: Colors.blue,
                child: Text(
                  'Want to Register ??',
                  style: textStyle.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  eventDescriptionScreen();
                },
              ),
              constraints: BoxConstraints.tightFor(width: 200.0, height: 50.0),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: double.infinity,
                      // margin: EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Image.network(widget.event.imageUrl,
                          fit: BoxFit.fitWidth)),
                ),
              ),
              Text(widget.event.eventName,
                  style: textStyle.copyWith(
                      fontSize: 20.0, fontWeight: FontWeight.w700)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text("by ${_getBranchLong(widget.event.organizedDept)}",
                        style: textStyle.copyWith(
                            fontSize: 12.0, fontStyle: FontStyle.italic)),
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _getChips()),
                ],
              ),
              Divider(
                height: 2.0,
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Text(
                      "Event Description",
                      style: textStyle.copyWith(fontSize: 19.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        sampleText,
                        style: textStyle.copyWith(
                            letterSpacing: 0.1, fontSize: 14.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 2.0,
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Text(
                      "Event Rules",
                      style: textStyle.copyWith(fontSize: 19.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        sampleText.replaceAll(".", ".\n -"),
                        style: textStyle.copyWith(
                            letterSpacing: 0.1, fontSize: 14.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 2.0,
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Text(
                      "Event Details",
                      style: textStyle.copyWith(fontSize: 19.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        sampleText.replaceAll(".", ".\n -"),
                        style: textStyle.copyWith(
                            letterSpacing: 0.1, fontSize: 14.0),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 2.0,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Any Queries ?",
                          style: textStyle.copyWith(fontSize: 19.0),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      widget.event.cordinators.keys.toList()[0],
                                      style: textStyle,
                                    ),
                                    Text(
                                     '(Co-ordinator)',
                                      style: textStyle.copyWith(
                                        fontSize: 11.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                ActionChip(
                                  onPressed: () {
                                    _launchUrl(widget.event.cordinators.values
                                        .toList()[0]
                                        .toString());
                                  },
                                  label: Text(
                                    "Call",
                                    style:
                                        textStyle.copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50.0,
                            width: 1.0,
                            color: Colors.grey,
                          ),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      widget.event.cordinators.keys.toList()[1],
                                      style: textStyle,
                                    ),
                                    Text(
                                      "(Co-ordinator)",
                                      style: textStyle.copyWith(
                                        fontSize: 11.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                ActionChip(
                                  onPressed: () {
                                    _launchUrl(widget.event.cordinators.values
                                        .toList()[1]
                                        .toString());
                                  },
                                  label: Text(
                                    "Call",
                                    style:
                                        textStyle.copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl(String phoneno) async {
    if (await canLaunch('tel:' + phoneno)) {
      launch('tel:' + phoneno);
    } else {
      print("url launch exception caught");
      throw "Could not launch " + phoneno;
    }
  }
}
