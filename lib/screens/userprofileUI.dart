import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promethean_2k19/data_models/userinfo.dart';
import 'package:promethean_2k19/screens/authScreen.dart';
import 'package:promethean_2k19/screens/registeredEvents.dart';
import 'package:promethean_2k19/screens/user_profile.dart';
import 'package:promethean_2k19/utils/aboutapp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:app_review/app_review.dart';
// import '../main.dart';

class UserProfileUI extends StatefulWidget {
  final UserInfo userInfo;

  const UserProfileUI({Key key, this.userInfo}) : super(key: key);
  @override
  _UserProfileUIState createState() => _UserProfileUIState();
}

class _UserProfileUIState extends State<UserProfileUI> {
  ScrollController controller;
  static BuildContext _context;
  // String imageurl;
  String appID;
  String outPut;

  Future<List<Widget>> _getdownloadUrls() async {
    List<Widget> temp = [];
    await http
        .get("https://promethean2k19-68a29.firebaseio.com/profileImages.json")
        .then((http.Response response) {
      Map<String, dynamic> map = json.decode(response.body);
      map.forEach((String uniqueId, dynamic value) {
        temp.add(buildCircularProfilePicture(
          context,
          imageUrl: value,
        ));
      });
    });
    print("After Getting Profile Images");
    print(temp);
    return temp;
  }

  Future<bool> changeProfilePicture({@required String imageurl}) async {
    // print("The Image Need to be changed is: "+imageurl);
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String uid = _prefs.get('uid');
    String insertionId;
    Map<String, dynamic> insertMap = {
      'branch': widget.userInfo.branch,
      'college': widget.userInfo.college,
      'email': widget.userInfo.email,
      'phone': widget.userInfo.phone,
      'rollNo': widget.userInfo.rollNo,
      'userName': widget.userInfo.userName,
      'year': widget.userInfo.year,
      'profilePic':
          'https://firebasestorage.googleapis.com/v0/b/promethean2k19-68a29.appspot.com/o/profile_images%2Fthor_Hulk.png?alt=media&token=2f964c3d-8e52-4875-9824-7ea31ebd8a56'
    };
    insertMap['profilePic'] = imageurl;
    await http
        .get(
            "https://promethean2k19-68a29.firebaseio.com/users/$uid/userInfo.json")
        .then((http.Response response) async {
      // print("The response got from the UserInfo is: "+response.body);
      Map<String, dynamic> map = json.decode(response.body);
      map.forEach((String uniqueId, dynamic value) {
        print(uniqueId);
        insertionId = uniqueId;
      });
      await http
          .put(
              "https://promethean2k19-68a29.firebaseio.com/users/$uid/userInfo/$insertionId.json",
              body: json.encode(insertMap))
          .then((http.Response response) {
        print("The Response Body after updating is: " + response.body);
        print("Profile Pic Updated Successfully");
      });
      // print("The user Info unique code is: "+map[0]);
    });
    return true;
  }

  Widget buildCircularProfilePicture(BuildContext context,
      {@required imageUrl}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print("Profile Pic change requested");
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return FutureBuilder<bool>(
                    future: changeProfilePicture(imageurl: imageUrl),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
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
                                                color: Colors.black,
                                                fontSize: 18.0),
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
                            return CupertinoAlertDialog(
                              title: Text("Sorry"),
                              content: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Something Went Wrong please ary after Sometime"),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("OK"),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          } else {
                            return CupertinoAlertDialog(
                              title: Text("Success"),
                              content: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text("Profile photo updated successfully"),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("OK"),
                                  onPressed: (){
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
                                      return UserProfile();
                                    }));
                                  },
                                )
                              ],
                            );
                          }
                      }
                    },
                  );
                });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, blurRadius: 1.0, spreadRadius: 1.0)
              ],
            ),
            child: ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.25),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.width * 0.25,
                decoration:
                    ShapeDecoration(shape: CircleBorder(), color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.0111),
                  child: DecoratedBox(
                    child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.25),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          print("error in network card $error\n with url $url");
                          return Container(
                              child:
                                  Center(child: CircularProgressIndicator()));
                        },
                        placeholder: (context, url) => Center(
                          child: Container(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static logout() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool t = await _prefs.clear();
    print(t);
    Navigator.of(_context).pop();
    Navigator.of(_context).pop();

    Navigator.of(_context).pushReplacement(
        CupertinoPageRoute(builder: (BuildContext context) => AuthScreen()));
  }

  static confirmDialog() {
    showDialog(
        context: _context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  logout();
                },
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
            content: Container(
              decoration: BoxDecoration(
                  // color: Colors.white,
                  ),
              child: Text("Do you Really want to Logout ?"),
            ),
          );
        });
  }

  static showReportDeveloper() {
    AlertDialog(
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            logout();
          },
          child: Text("Send"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(_context).pop();
          },
          child: Text("Cancel"),
        ),
      ],
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Text("Press Ok to Logout?"),
      ),
    );
  }

  List<String> title = [];

  List<Widget> iconElement = [
    Icon(
      Icons.phone,
      size: 20.0,
      color: Colors.blueAccent,
    ),
    Icon(
      Icons.mail_outline,
      size: 20.0,
      color: Colors.redAccent,
    ),
    ImageIcon(
      AssetImage('assets/college.png'),
      size: 20.0,
      color: Colors.brown[300],
    ),
    ImageIcon(
      AssetImage('assets/branch.png'),
      size: 20.0,
      color: Colors.orange[300],
    ),
  ];
  List<String> functionTitles = [
    "Registered Events",
    "Report Developer",
    "About App",
    "Will You Rate Us ?",
    "Log out"
  ];

  static Future<bool> sleep() async {
    await Future.delayed(Duration(seconds: 3)).then((onValue) {});
    return true;
  }

  static _buildDeveloperReport() {
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("Report a bug"),
            content: Material(
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: "Name the Screen error occured",
                          hintStyle: TextStyle(fontFamily: 'QuickSand')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: "Describe the bug",
                          hintStyle: TextStyle(fontFamily: 'QuickSand')),
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Submit"),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FutureBuilder<bool>(
                          future: sleep(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                              case ConnectionState.active:
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
                                                      color: Colors.black,
                                                      fontSize: 18.0),
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
                                  return CupertinoAlertDialog(
                                    title: Text("Sorry"),
                                    content: Text("Something Went Wrong"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                } else {
                                  return CupertinoAlertDialog(
                                    title: Text("Thank You"),
                                    content: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12,
                                          bottom: 8,
                                          left: 8,
                                          right: 8),
                                      child: Text(
                                          "We will rectify the bug as soon as possible"),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                }
                            }
                          },
                        );
                      });
                },
              ),
            ],
          );
        });
  }

  List<Function> onpresseFunctions = [
    () async {
      /// Naviagate to Registered Events
      print("Navigating to Registered Events");
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      String uid = _prefs.get('uid');
      Navigator.push(_context,
          CupertinoPageRoute(builder: (BuildContext context) {
        return Scaffold(
            appBar: new AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              elevation: 3.0,
              title: new Text(
                "Registered Events",
                style: new TextStyle(
                  color: Colors.black,
                  fontFamily: 'bebas-neue',
                  fontSize: 25.0,
                ),
              ),
            ),
            body: RegisteredEvents(uid));
      }));
    },
    () {
      ///for reporting developers as review
      print("Reporting to developer");
      _buildDeveloperReport();
    },
    () {
      ///for About App Dialog
      showGalleryAboutDialog(_context);
      print("about APP");
    },
    () {
      /// for user to rate the app
      print("Rate the App");
      AppReview.storeListing.then((onValue) {
        print(onValue);
      });
    },
    () {
      // for log out
      print("clearing all");
      confirmDialog();
    }
  ];

  List<String> buttonIcons = [
    'assets/registeredEvents.png',
    'assets/bugs.png',
    'assets/aboutApp.png',
    'assets/rating.png',
    'assets/logOut.png',
  ];
  // List<Color> buttonIconColors =[
  Color toogleColor = Colors.white;
  // ];

  TextStyle lableStyle = const TextStyle(
    color: Colors.white,
    fontFamily: 'QuickSand',
    fontSize: 50.0,
    fontWeight: FontWeight.bold,
  );
  double textScale = 1;

  @override
  void initState() {
    // imageurl="assets/pic.jpg";
    title.add(widget.userInfo.phone);
    title.add(widget.userInfo.email);
    title.add(widget.userInfo.college);
    title.add(widget.userInfo.branch);
    controller = new ScrollController();
    controller.addListener(onScroll);
    AppReview.getAppID.then((onValue) {
      setState(() {
        appID = onValue;
      });
      print("The Application Id is: " + appID);
    });
    super.initState();
  }

  void onScroll() {
    // print("controller offset $controller.offset");

    if (controller.offset < 1) {
      textScale = 1;
      // print("moving g");
    } else {
      textScale = 1 - controller.offset * 0.006;
      textScale = textScale.clamp(0.0, 1.0);
      // print("textScale: $textScale");
      // print("moving S");
    }
    setState(() {
      if (textScale < 0.3) {
        toogleColor = Colors.blueGrey;
      } else
        toogleColor = Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 135.0),
                    child: Transform(
                      transform:
                          Matrix4.translationValues(0.0, -textScale * 5, 0.0),
                      child: Transform.scale(
                        scale: textScale,
                        child: Text(
                          "User Profile",
                          style: lableStyle.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.08),
                        ),
                      ),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                    Color(0xFFf9c1c4),
                    Color(0xFFffc892),
                  ]),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            controller: controller,
            physics: ClampingScrollPhysics(),
            child: Container(
              // height: 200.0,
              margin: EdgeInsets.symmetric(horizontal: 6),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 135.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Container(
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 1.0,
                                      spreadRadius: 0.0,
                                    )
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40.0),
                                      topRight: Radius.circular(40.0))),
                              width: double.infinity,
                              // height: 100.0,
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 50.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 120.0,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20.0),
                                        child: Text(
                                          widget.userInfo.userName,
                                          style: lableStyle.copyWith(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            color: Colors.deepOrangeAccent[200],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Divider(
                                          height: 5.0,
                                          color: Colors.blueGrey[100],
                                        ),
                                      ),
                                      Column(
                                        children: [0, 1, 2, 3]
                                            .map((index) => buildDetails(index))
                                            .toList(),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: Divider(
                                            height: 5.0,
                                            color: Colors.blueGrey[100],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Column(
                                          children: [0, 1, 2, 3, 4]
                                              .map((index) =>
                                                  buildButtons(index))
                                              .toList(),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                          buildCircularProfilePic(context),
                        ],
                      ),
                      // color: Colors.cyan,
                    ),
                  ),
                ],
              ),
              // color: Colors.pinkAccent[200],
            ),
          ),
          Positioned(
            top: 25.0,
            left: 6.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: toogleColor, size: 25.0),
              onPressed: () {
                print("back");
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            top: 25.0,
            right: 6.0,
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: toogleColor,
                size: 25.0,
              ),
              onPressed: () {
                print("Profiles display Dialogue");
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return FutureBuilder<List<Widget>>(
                        future: _getdownloadUrls(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Widget>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                              print(snapshot.data);
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
                                                    color: Colors.black,
                                                    fontSize: 18.0),
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
                              print(snapshot.data);
                              if (snapshot.hasError) {
                                return Container(
                                  height: 59,
                                  color: Colors.white,
                                  child: Center(
                                    child: Material(
                                      color: Colors.white,
                                      child: Text(
                                        "Please Check your Network Connection and Try again",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'QuickSand',
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 14, top: 14),
                                          child: Material(
                                            child: Text(
                                              "Select Your Profile Picture",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  fontFamily: 'QuickSand'),
                                            ),
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Wrap(
                                            children: snapshot.data,
                                            alignment:
                                                WrapAlignment.spaceEvenly,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          }
                        },
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildButtons(int index) {
    return Container(
      margin: EdgeInsets.only(left: 15.0),
      child: MaterialButton(
        onPressed: onpresseFunctions[index],
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 25.0,
                      maxWidth: 30.0,
                      minHeight: 20.0,
                      minWidth: 20.0),
                  child: Image.asset(
                    buttonIcons[index],
                    fit: BoxFit.scaleDown,
                  )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(functionTitles[index],
                    style: lableStyle.copyWith(
                        fontSize: 17.0, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetails(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, top: 10.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(child: iconElement[index]),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(title[index],
                  style:
                      lableStyle.copyWith(fontSize: 17.0, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCircularProfilePic(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 1.0, spreadRadius: 1.0)
        ],
      ),
      child: ClipRRect(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.width * 0.35),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.35,
          height: MediaQuery.of(context).size.width * 0.35,
          decoration:
              ShapeDecoration(shape: CircleBorder(), color: Colors.white),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.0177),
            child: DecoratedBox(
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.35),
                child: CachedNetworkImage(
                  imageUrl: widget.userInfo.profilePic,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    print("error in network card $error\n with url $url");
                    return Container(
                        child: Center(child: CircularProgressIndicator()));
                  },
                  placeholder: (context, url) => Center(
                    child: Container(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: CircleBorder(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
