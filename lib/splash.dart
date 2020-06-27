import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'globals.dart' as globals;

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _getUser(context);
    return Scaffold(
      body: Center(
        child: const Text("スプラッシュ画面"),
      ),
    );
  }

  void _getUser(BuildContext context) async {
    try {
      globals.firebaseUser = await globals.auth.currentUser();
      if (globals.firebaseUser == null) {
        await globals.auth.signInAnonymously();
        globals.firebaseUser = await globals.auth.currentUser();
      }
      Navigator.pushReplacementNamed(context, '/list');
    } catch (e) {
      Fluttertoast.showToast(msg: 'ログインに失敗しました．');
    }
  }
}
