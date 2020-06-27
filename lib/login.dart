import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'globals.dart' as globals;
import 'data_field.dart';

void showBasicDialog(BuildContext context) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email, password;

  if (globals.firebaseUser.isAnonymous) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("ログイン/登録ダイアログ"),
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.mail),
                  labelText: 'Email',
                ),
                onSaved: (String value) {
                  email = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Emailは必須入力項目です．';
                  }
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.vpn_key),
                  labelText: 'Password',
                ),
                onSaved: (String value) {
                  password = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Passwordは必須入力項目です．';
                  }
                  if (value.length < 6) {
                    return 'Passwordは6桁以上です．';
                  }
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('キャンセル'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: const Text('登録'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _createUser(context, email, password);
              }
            },
          ),
          FlatButton(
            child: const Text('ログイン'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _signIn(context, email, password);
              }
            },
          )
        ],
      ),
    );
  } else {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("確認ダイアログ"),
              content: Text(globals.firebaseUser.email + "でログインしています"),
              actions: <Widget>[
                FlatButton(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: const Text('ログアウト'),
                  onPressed: () {
                    globals.auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (_) => false);
                  },
                )
              ],
            ));
  }
}

void _signIn(BuildContext context, String email, String password) async {
  try {
    await globals.auth
        .signInWithEmailAndPassword(email: email, password: password);
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  } catch (e) {
    Fluttertoast.showToast(msg: 'ログインに失敗しました．');
  }
}

void _createUser(BuildContext context, String email, String password) async {
  try {
    globals.auth
        .createUserWithEmailAndPassword(email: email.trim(), password: password)
        .then((currentUser) => Firestore.instance
                .collection(UserField.collection)
                .document(currentUser.user.uid)
                .setData({
              UserField.userId: currentUser.user.uid,
              UserField.displayName: email.trim(),
              UserField.email: email.trim(),
            }))
        .then((result) =>
            {Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false)});
  } catch (e) {
    Fluttertoast.showToast(msg: 'ユーザ登録に失敗しました．');
  }
}
