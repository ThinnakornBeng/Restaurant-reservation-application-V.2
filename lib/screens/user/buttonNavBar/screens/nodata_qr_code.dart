import 'package:flutter/material.dart';

class NoDataQRCode extends StatefulWidget {
  const NoDataQRCode({Key key}) : super(key: key);

  @override
  _NoDataQRCodeState createState() => _NoDataQRCodeState();
}

class _NoDataQRCodeState extends State<NoDataQRCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ไม่พบขอมูลของคิวอาร์โค้ด'),
          ],
        ),
      ),
    );
  }
}
