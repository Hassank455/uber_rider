import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider_app/AllScreens/loginScreen.dart';
import 'package:uber_rider_app/AllScreens/mainscreen.dart';
import 'package:uber_rider_app/AllWidgets/progressDialog.dart';
import 'package:uber_rider_app/main.dart';

class RegisterationScreen extends StatelessWidget {
  static const String idScreen = "register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 35.0),
              Image(
                image: AssetImage("assets/images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 1.0),
              Text(
                'Register as a Rider',
                style: TextStyle(fontSize: 24.0, fontFamily: 'Brand Bold'),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(height: 1.0),
                    TextFormField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 1.0),
                    TextFormField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 1.0),
                    TextFormField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 1.0),
                    TextFormField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(height: 10.0),
                    RaisedButton(
                      color: Colors.yellow,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            'Greate Account',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                            ),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        if (nameTextEditingController.text.length < 3) {
                          dispalyToastMessage(
                              'Name must be atleast 3 character', context);
                        } else if (!emailTextEditingController.text
                            .contains("@")) {
                          dispalyToastMessage(
                              'Email address is not valid', context);
                        } else if (phoneTextEditingController.text.isEmpty) {
                          dispalyToastMessage(
                              'Phone Number is not empty', context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          dispalyToastMessage(
                              'password must be atleast 6 character', context);
                        } else {
                          registerNewUser(context);
                        }
                      },
                    )
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: Text('Already have an Account? Login Here'),
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {

    showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
      return ProgressDialog(message: "Register, Please wait....",);
    });

    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      dispalyToastMessage('Error' + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      //user created
      //save user info on database

      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      usersRef.child(firebaseUser.uid).set(userDataMap);
      dispalyToastMessage('Congratulation', context);
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      dispalyToastMessage('new User account has not be created', context);
    }
  }
}

dispalyToastMessage(String msg, BuildContext context) {
  Fluttertoast.showToast(msg: msg);
}
