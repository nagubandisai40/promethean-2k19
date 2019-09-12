import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promethean_2k19/common/helper.dart';
import 'package:promethean_2k19/common/messageBox.dart';
import 'package:promethean_2k19/screens/home_screen.dart';
import 'package:promethean_2k19/screens/profile_form.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textcontroller = new TextEditingController();
  final TextEditingController smsController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isTypedPhoneNumber = false;
  bool _isTypedsms = false;
  final FirebaseAuth _firebseAuth = FirebaseAuth.instance;

  String verificationId;
  String smsCode;

  AnimationController animationController;
  Animation<double> animation;
  bool _isLoading = false;
  @override
  void initState() {
    animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() => setState(() {}));
    animation = new CurvedAnimation(
      parent: animationController,
      curve: new Interval(0.0, 1, curve: Curves.easeIn),
    );
    super.initState();
  }

  String get phoneNumber {
    String _phoneNumber;
    try {
      String unmaskedText = _textcontroller.text;

      if (unmaskedText != null) _phoneNumber = "+91 $unmaskedText".trim();
    } catch (error) {
      print("error 43");
    }
    return _phoneNumber;
  }

  Future<void> verifyPhoneNumber() async {
    LoadingMessageBox(context, "Sending OTP", "").show();
    _isLoading = true;
    print("verification started ");
    codeAutoRetrievalTimeout(String value) {
      // _isLoading == true
      //     ? Navigator.of(context).pop(true)
      //     : print("not loading so didnt pop");

      print("code autoritrival timeout");
    }

    codeSent(String verificationId, [int forceResendingToken]) {
      this.verificationId = verificationId;
      print("onCode we set verificationid");
      if (_isLoading) {

      print("loading pop");

        Navigator.of(context).pop(true);
        _isLoading = false;
      } else
        print("not loading so didnt pop");

      setState(() {
        animationController.forward();
      });
    }

    verificationCompleted(AuthCredential phoneAuthCredential) {
      print("on verification completed ");
      // setState(() {
      //   smsController.text = verificationId;
      // });
      signInWithPhone(credential: phoneAuthCredential);
    }

    verificationFailed(AuthException error) {
      
      print("on verificationFailed ${error.code}");
      if(_isLoading){
        print("pop");
         _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(error.code),
          ));
        Navigator.of(context).pop(true);
      }
      else{
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Something went wrong. Please try again'),
          ));
      }
    }

    print("loading");

    await _firebseAuth.verifyPhoneNumber(
      phoneNumber: this.phoneNumber,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      codeSent: codeSent,
      timeout: const Duration(seconds: 2),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
    );
  }

  signInWithPhone({AuthCredential credential}) {
    print("signIn phone called ");
    if (credential != null) {
      print("linr 106 passed from auto ");
      FirebaseAuth.instance.signInWithCredential(credential).catchError((E, T) {
        if (E.toString().contains("ERROR_INVALID_VERIFICATION_CODE")) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Invalid Verification Code"),
          ));
        }
        print(E);
      }).then((user) {
        if (user != null) {
          print("verified ${user.phoneNumber}");
          print(user.uid);
          Helper.finishingTaskAfterSignIn(user);
          //next task is userInfo
          LoadingMessageBox(context, "Fetching User Proflie", "").show();
          Helper.checkUserInfoInDB(uid: user.uid).then((value) {
            if (value) {
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (BuildContext context) => HomeScreen()));
            } else {
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (BuildContext context) => UserProfileForm()));
            }
          });
        } else {
          print("failed to phone Auth");
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Something went wrong !!"),
          ));
          return;
        }
      });
    } else {
      FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.getCredential(
        verificationId: this.verificationId,
        smsCode: this.smsCode,
      ))
          .catchError((E, T) {
        if (E.toString().contains("ERROR_INVALID_VERIFICATION_CODE")) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Invalid Verification Code"),
          ));
        }
        print(E);
      }).then((user) {
        if (user != null) {
          print("verified ${user.phoneNumber}");
          print(user.uid);
          Helper.finishingTaskAfterSignIn(user);
          //next task is userInfo
          LoadingMessageBox(context, "Fetching User Proflie", "").show();
          Helper.checkUserInfoInDB(uid: user.uid).then((value) {
            if (value) {
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (BuildContext context) => HomeScreen()));
            } else {
              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (BuildContext context) => UserProfileForm()));
            }
          });
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Something went wrong !!"),
          ));
          return;
        }
      });
    }
  }

  showDialogOTP() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Enter OTP"),
                Container(
                  width: 100.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "_ _ _ _ _ _",
                        hintStyle: TextStyle(color: Colors.grey)),
                    maxLength: 6,
                    onChanged: (String value) {
                      this.smsCode = value;
                    },
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    FirebaseAuth.instance.currentUser().then((user) {
                      if (user != null) {
                        Navigator.of(context).pop();
                        print("the user signed in and we need to set Userinfo");
                      } else {
                        // Navigator.of(context).pop();
                        signInWithPhone();
                      }
                    });
                  },
                  child: Text("Verify OTP"),
                ),
                Text("Resend OTP in counter.."),
              ],
            ),
          );
        });
  }

  Size _deviceSize;

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return Hero(
      tag: "PhoneAuth",
      child: Scaffold(
          key: _scaffoldKey,
          // appBar: AppBar(
          //   elevation: 0.0,
          //   backgroundColor: Colors.white,
          // ),
          backgroundColor: Colors.white,
          body: Stack(children: <Widget>[
            Opacity(
                opacity: (1 - animationController.value).abs(),
                child: getPhoneSection(_deviceSize)),
            Opacity(
              opacity: animationController.value,
              child: SlideTransition(
                  position: animation.drive(Tween<Offset>(
                    begin: const Offset(0.0, 4),
                    end: const Offset(0.0, 0.0),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: buildOPTSection(_deviceSize),
                  )),
            ),
          ])),
    );
  }

  Widget buildOPTSection(Size deviceSize) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            color: Colors.black,
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                animationController.reverse();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment(-0.7, 0.0),
            child: Text(
              "Enter Recieved OTP here",
              style: TextStyle(
                  fontFamily: 'QuickSand',
                  fontSize: deviceSize.width * 0.06,
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Icon(Icons.sms),
            title: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: TextField(
                controller: smsController,
                textAlign: TextAlign.center,
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[0-9]")),
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: "_ _ _ _ _ _",
                    hintStyle: TextStyle(color: Colors.grey)),
                maxLength: 6,
                onChanged: (String value) {
                  setState(() {
                    _isTypedsms = value.length < 6 ? false : true;
                  });
                },
              ),
            ),
          ),
        ),
        Wrap(alignment: WrapAlignment.center, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(29.0),
            child: Text(
              "Auto Verifiing Code,",
              style: TextStyle(fontSize: 10.0, color: Colors.grey),
            ),
          )
        ]),
        Opacity(
          opacity: _isTypedsms ? 1 : 0.2,
          child: AbsorbPointer(
            absorbing: !_isTypedsms,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              color: Colors.lightBlue,
              onPressed: () {
                this.smsCode = smsController.text;
                print("$smsCode");
                signInWithPhone();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Submmit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getPhoneSection(Size deviceSize) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
          child: Align(
            alignment: Alignment(-0.7, 0.0),
            child: Text(
              "My number is",
              style: TextStyle(
                  fontFamily: 'QuickSand',
                  fontSize: deviceSize.width * 0.08,
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Icon(Icons.phone_android),
            title: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: SizedBox(
                height: deviceSize.height * 0.06,
                child: CupertinoTextField(
                  onChanged: (String value) {
                    print("${value.length} $_isTypedPhoneNumber");
                    setState(() {
                      _isTypedPhoneNumber = value.length < 10 ? false : true;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[0-9]")),
                  ],
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        width: 2.0,
                        color: Colors.grey,
                      )),
                  controller: _textcontroller,
                  cursorColor: Colors.green,
                ),
              ),
            ),
          ),
        ),
        Wrap(alignment: WrapAlignment.center, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(29.0),
            child: Text(
              "When you tap on 'Continue', ©Promethene2K19 will send a  text with verification code. The verified User can use the Services of Promethene2K19.",
              style: TextStyle(fontSize: 10.0, color: Colors.grey),
            ),
          )
        ]),
        Opacity(
          opacity: _isTypedPhoneNumber ? 1 : 0.2,
          child: AbsorbPointer(
            absorbing: !_isTypedPhoneNumber,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              color: Colors.lightBlue,
              onPressed: () {
                verifyPhoneNumber();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
