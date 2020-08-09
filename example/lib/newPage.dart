import 'package:flutter/material.dart';
import 'package:flutter_openvpn/flutter_openvpn.dart';
import 'package:flutter_openvpn_example/main.dart';

class NewPAge extends StatelessWidget {
  static String subPath = '/page';

  final String page;
  final bool navigate;
  NewPAge(this.page, this.navigate);
  @override
  Widget build(BuildContext context) {
    if (page == '0') FlutterOpenvpn.init();
    if (page == '2') MyApp.initPlatformState();
    if (navigate) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context)
            .popAndPushNamed(subPath + (int.parse(page) + 1).toString());
      });
    }
    return Scaffold(
      body: Center(
        child: Center(
          child: Text(
            page.toString(),
          ),
        ),
      ),
    );
  }
}
