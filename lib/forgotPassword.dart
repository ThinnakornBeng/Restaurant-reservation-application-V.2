import 'package:b_queue/utility/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resert Password'),
      ),
      body: Center(
        child: Column(
          children: [
            textFormFieldPassword(context),
            elevatedButtonSentYourEmail(context)
          ],
        ),
      ),
    );
  }

  Container elevatedButtonSentYourEmail(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width * 0.6,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          processForgot();
        },
        child: Text(
          'Sent',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Container textFormFieldPassword(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: emailController,
        decoration: InputDecoration(
          label: Text('Please your enter email'),
          prefixIcon: Icon(
            Icons.email,
            size: 30,
            color: Colors.red,
          ),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> processForgot() async {
    Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text)
          .then(
            (value) => normalDialog(
                context, 'GO to your Email Address resrt password'),
          )
          .catchError((error) {
        normalDialog(context, error.message);
      });
    });
  }
}
