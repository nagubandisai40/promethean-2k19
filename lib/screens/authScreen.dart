import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:promethean_2k19/common/helper.dart';
import 'package:promethean_2k19/common/messageBox.dart';
import 'package:promethean_2k19/screens/auth/phoneAuth.dart';
import 'package:promethean_2k19/screens/home_screen.dart';
import 'package:promethean_2k19/screens/profile_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GoogleSignIn _googleSignIn = new GoogleSignIn();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

 Future<Null> googleSignIn() async {
    GoogleSignInAccount googleSignInAccount = _googleSignIn.currentUser;
    googleSignInAccount = await _googleSignIn.signIn().catchError((E, R) {
      print("error $E");
    });
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
      FirebaseAuth.instance
          .signInWithCredential(GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      )).catchError((E, R) {
        print(E);
        if(E.toString().contains("PlatformException(FirebaseException, An internal error has occurred. [ 7: ], null)"))
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Something went Wrong, please check your device network connection"),));
          return;
      }).then((user) {
        if (user != null) {
          print(user.email);
          ///this set the uid and iA keys to sharedpreferences 
          Helper.finishingTaskAfterSignIn(user);
          /// next task is userInfo 
          LoadingMessageBox(context, "Fetching User Proflie", "").show();    
          Helper.checkUserInfoInDB(uid:user.uid).then((value){
             if(value){
               Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (BuildContext context) =>HomeScreen()));
             }
             else { 
             Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (BuildContext context) => UserProfileForm()));
            }
          });
        } else {
          print("failed googleSign");
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Something thing went wrong"),));
          return null;
        }
      });
    }
    else{
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Failed to get google account"),));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              width: double.infinity,
              // height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF861657),
                      Color(0xFFFFA69E),
                    ]),
              ),
            ),
            Positioned(
              top: 30.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints.expand(
                      width: MediaQuery.of(context).size.height * 0.25,
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Card(
                          color: Colors.transparent,
                          elevation: 13.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Container(
                              width: MediaQuery.of(context).size.height * 0.3,
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Image.asset(
                                "assets/steak_on_cooktop.jpg",
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      // color: Colors.white,
                      ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: ["SignIn with Phone", "SignIn with Google"]
                              .map((value) {
                            bool _isPhone = value.contains("Phone");
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: _isPhone
                                      ? () {
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          PhoneAuth()));
                                        }
                                      : () {
                                          print("_signIn");
                                          googleSignIn();
                                        },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: _isPhone
                                              ? Colors.blue
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      child: Center(
                                          child: Text(
                                        value,
                                        style: TextStyle(
                                          color: _isPhone
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ))),
                                ));
                          }).toList() +
                          [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        print("terms and Conditions");
                                      },
                                      child: Text.rich(TextSpan(
                                          text:
                                              " By continuning you Aggree to ®Promethene2K19  ",
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: "Terms and Conditions",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ])),
                                    ),
                                  ]),
                            )
                          ])),
            )
          ],
        ),
      ),
    );
  }
}

