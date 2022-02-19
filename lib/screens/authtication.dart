import 'package:b_queue/forgotPassword.dart';
import 'package:b_queue/model/user_model.dart';
import 'package:b_queue/screens/register.dart';
import 'package:b_queue/screens/restaurant/navbar/navRest.dart';
import 'package:b_queue/screens/user/navbar/navUser.dart';
import 'package:b_queue/utility/colors.dart';
import 'package:b_queue/utility/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  double screens;
  bool statusRedEye = true;
  String email, password, name, uid, avatarUrl;
  bool status = true;
  String typeUser = 'user';
  String token, titleNoti, bodyNoti;

  @override
  void initState() {
    super.initState();
    setUPMessaging();
    // setUpNotification();
  }

  Future<void> onselectNoti(String string) async {
    if (string != null) {
      print('Doing ??? Aletr Click Noti');
    }
  }

  Future<void> setUPMessaging() async {
    Firebase.initializeApp().then((value) async {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      token = await firebaseMessaging.getToken();
      print('Token is ===>>> $token');
      checkStatus();
    });

    // for FonEnd Service
    FirebaseMessaging.onMessage.listen((event) {
      titleNoti = event.notification.title;
      bodyNoti = event.notification.body;
      // print('Form Fontend titleNoti == $titleNoti, bodeyNoti == $bodyNoti');
      // processShoeLocalNoti();
    });

    // for BlackEnd Service
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      titleNoti = event.notification.title;
      bodyNoti = event.notification.body;
      // print('form BlackEnd titleNoti == $titleNoti, bodeyNoti == $bodyNoti');
      // processShoeLocalNoti();
    });
  }

  Future<Null> checkStatus() async {
    await Firebase.initializeApp().then(
      (value) async {
        await FirebaseAuth.instance.authStateChanges().listen(
          (event) async {
            if (event != null) {
              String uid = event.uid;
              // print('uid = $uid');

              Map<String, dynamic> map = {};
              map['token'] = token;

              await FirebaseFirestore.instance
                  .collection('userTable')
                  .doc(uid)
                  .update(map)
                  .then(
                    (value) => print('Up Date Token success'),
                  );

              FirebaseFirestore.instance
                  .collection('userTable')
                  .doc(uid)
                  .snapshots()
                  .listen(
                (event) {
                  UserModel model = UserModel.fromMap(event.data());
                  // print('type = ${model.userType}');
                  switch (model.userType) {
                    case 'restaurant':
                      routeToPage(NavigationBarRestaurant());
                      upDateTokenRestaurant();
                      break;
                    case 'user':
                      routeToPage(NavigationBarUser());
                      break;

                    default:
                      // print('### Con not Type ###');
                      routeToPage(Authentication());
                      break;
                  }
                },
              );
            } else {
              setState(
                () {
                  status = false;
                },
              );
            }
          },
        );
      },
    );
  }

  Future<void> upDateTokenRestaurant() async {
    Firebase.initializeApp().then((value) async {
      FirebaseAuth.instance.authStateChanges().listen((event) {
        String uidRest = event.uid;

        Map<String, dynamic> map = {};
        map['token'] = token;
        FirebaseFirestore.instance
            .collection('restaurantTable')
            .doc(uidRest)
            .update(map)
            .then((value) => print('UpDate Token Restaurant Success'));
      });
    });
  }

  void routeToPage(Widget widget) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => widget,
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    screens = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 450,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: screens * 0.4,
                        child: Image.asset(
                          'images/logo.png',
                          width: screens * 0.4,
                        )),
                    emailForm(),
                    prasswordForm(),
                    textButtonForgotPassword(context),
                    loginButton(),
                    signinWithGoogle(),
                    // signinWithFacebook(),
                    textRegister(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textButtonForgotPassword(BuildContext context) {
    return Container(
      width: screens * 0.75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPassword(),
                )),
            child: Text(
              'ลืมรหัสผ่าน !',
              style: TextStyle(color: primaryColor,
                fontStyle: FontStyle.italic,fontSize: 16
                // decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signinWithFacebook() {
    return Container(
      width: screens * 0.55,
      child: SignInButton(
        Buttons.Facebook,
        onPressed: () {},
      ),
    );
  }

  Widget signinWithGoogle() {
    return Container(
      width: screens * 0.55,
      margin: EdgeInsets.only(top: 10),
      child: SignInButton(
        Buttons.Google,
        onPressed: () {
          checkSingInWithGoogle();
        },
      ),
    );
  }

  Future<Null> checkSingInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    await Firebase.initializeApp().then(
      (value) async {
        await _googleSignIn.signIn().then(
          (value) async {
            name = value.displayName;
            email = value.email;
            avatarUrl = value.photoUrl;

            await value.authentication.then(
              (value) async {
                AuthCredential authCredential = GoogleAuthProvider.credential(
                  idToken: value.idToken,
                  accessToken: value.accessToken,
                );

                await FirebaseAuth.instance
                    .signInWithCredential(authCredential)
                    .then(
                  (value) async {
                    uid = value.user.uid;
                    // print(
                    //     'Login With gmail Success Name == $name Email == $email Uid == $uid');

                    await FirebaseFirestore.instance
                        .collection('userTable')
                        .doc(uid)
                        .snapshots()
                        .listen((event) {
                      // print('Event ===>>> ${event.data()}');
                      if (event.data() == null) {
                        // Call TypeUser

                        callTypeUserDialog();
                      } else {
                        // Route to TypeUser
                        // print('Route Type User');
                      }
                    });
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Null> callTypeUserDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => SimpleDialog(
            title: ListTile(
              leading: Container(
                  width: 40, height: 40, child: Image.asset('images/logo.png')),
              title: Text('ประเภทผู้ใช้งาน'),
              subtitle: Text('กรุณาเลือกประเภทผู้ใช้งาน'),
            ),
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    RadioListTile(
                      activeColor: Colors.red,
                      value: 'user',
                      groupValue: typeUser,
                      onChanged: (value) {
                        setState(() {
                          typeUser = value;
                        });
                      },
                      title: Text('สำหรับลูกค้า'),
                    ),
                    RadioListTile(
                      activeColor: Colors.red,
                      value: 'restaurant',
                      groupValue: typeUser,
                      onChanged: (value) {
                        setState(() {
                          typeUser = value;
                        });
                      },
                      title: Text('สำหรับร้านอาหาร'),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // print(
                  //     ' Name == $name, TypeUser == $typeUser, Email == $email, Uid == $uid');
                  insertToCloudFirestore();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Null> insertToCloudFirestore() async {
    UserModel userModel = UserModel(
        name: name, email: email, userType: typeUser, imageProfile: avatarUrl);
    Map<String, dynamic> data = userModel.toMap();

    await Firebase.initializeApp().then(
      (value) async {
        FirebaseFirestore.instance
            .collection('userTable')
            .doc(uid)
            .set(data)
            .then(
          (value) async {
            switch (typeUser) {
              case 'restaurant':
                routeToPage(NavigationBarRestaurant());
                break;
              case 'user':
                routeToPage(NavigationBarUser());
                break;
              default:
            }
          },
        );
      },
    );
  }

  // Row showTextNameApp() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Container(
  //         margin: EdgeInsets.only(top: 2),
  //         child: Text(
  //           'B',
  //           style: TextStyle(
  //             fontSize: 25,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.blue,
  //           ),
  //         ),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(top: 2),
  //         child: Text(
  //           'e',
  //           style: TextStyle(
  //             fontSize: 25,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.green,
  //           ),
  //         ),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(top: 2),
  //         child: Text(
  //           'n',
  //           style: TextStyle(
  //               fontSize: 25, fontWeight: FontWeight.bold, color: Colors.amber),
  //         ),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(top: 2),
  //         child: Text(
  //           'g',
  //           style: TextStyle(
  //               fontSize: 25,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.orange),
  //         ),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(top: 2),
  //         child: Text(
  //           'Q',
  //           style: TextStyle(
  //               fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Container loginButton() {
    return Container(
      height: 45,
      // margin: EdgeInsets.only(top: 15),
      width: screens * 0.7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if ((email?.isEmpty ?? true) || (password?.isEmpty ?? true)) {
            normalDialog(
                context, 'Please enter your information in all fields.');
          } else {
            checkAuthen();
          }
        },
        child: Text(
          'เข้าสู่ระบบ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<Null> checkAuthen() async {
    await Firebase.initializeApp().then((value) async {});
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
      (value) async {
        String uid = value.user.uid;
        await FirebaseFirestore.instance
            .collection('userTable')
            .doc(uid)
            .snapshots()
            .listen(
          (event) {
            UserModel model = UserModel.fromMap(event.data());
            switch (model.userType) {
              case 'restaurant':
                routeToPage(NavigationBarRestaurant());
                break;
              case 'user':
                routeToPage(NavigationBarUser());
                break;
              default:
                print('### Con not Type ###');
                routeToPage(Authentication());
                break;
            }
          },
        );
      },
    ).catchError(
      (value) {
        normalDialog(context, value.message);
      },
    );
  }

  // Widget signInFacebook() => Container(
  //       margin: EdgeInsets.only(top: 5),
  //       child: SignInButton(Buttons.FacebookNew, onPressed: () {}),
  //     );

  // Widget signInGoogle() => Container(
  //       margin: EdgeInsets.only(top: 10),
  //       child: SignInButton(Buttons.GoogleDark, onPressed: () {}),
  //     );

  Container textRegister() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "คุณยังไม่มีบัญชีผู้ใช้งาน",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterApp(),
              ),
            ),
            child: Text(
              'สร้างตอนนี้ !',
              style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
          )
        ],
      ),
    );
  }

  Widget emailForm() => Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => email = value.trim(),
          decoration: InputDecoration(
            label: Text(
              'กรุณากรอกอีเมล์ของคุณ',
              style: TextStyle(color: Colors.black54),
            ),
            prefixIcon: Icon(
              Icons.email_rounded,
              color: primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color:primaryColor),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
      );

  Widget prasswordForm() => Container(
        width: screens * 0.85,
        margin: EdgeInsets.only(top: 10),
        child: TextField(
          onChanged: (value) => password = value.trim(),
          obscureText: statusRedEye,
          decoration: InputDecoration(
            label: Text(
              'กรุณาใส่รหัสผ่านของคุณ',
              style: TextStyle(color: Colors.black54),
            ),
            prefixIcon: Icon(
              Icons.password_rounded,
              color: primaryColor,
            ),
            suffixIcon: IconButton(
              icon: statusRedEye
                  ? Icon(
                      Icons.visibility_off_rounded,
                      color:primaryColor,
                    )
                  : Icon(
                      Icons.visibility_rounded,
                      color: primaryColor,
                    ),
              onPressed: () {
                setState(
                  () {
                    statusRedEye = !statusRedEye;
                  },
                );
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              borderSide: BorderSide(color:primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
      );
}
