import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share/share.dart';

import 'globals.dart' as globals;
import 'data_field.dart';

class InputForm extends StatefulWidget {
  InputForm(this.document);
  final DocumentSnapshot document;
  @override
  _MyInputFormState createState() => _MyInputFormState();
}

class _FormData {
  String borrowOrLend = "borrow";
  String user;
  String stuff;
  DateTime date = DateTime.now();
}

class _MyInputFormState extends State<InputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();

  Future<DateTime> _selectTime(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: _data.date,
        firstDate: DateTime(_data.date.year - 2),
        lastDate: DateTime(_data.date.year + 2));
  }

  void _setBorrowOrLend(String value) {
    setState(() {
      _data.borrowOrLend = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference _mainReference;
    bool isEdit = false;
    if (widget.document != null) {
      if (_data.user == null && _data.stuff == null) {
        _data.borrowOrLend = widget.document[DataField.borrowOrLend];
        _data.user = widget.document[DataField.user];
        _data.stuff = widget.document[DataField.stuff];
        _data.date = widget.document[DataField.date].toDate();
      }
      _mainReference = Firestore.instance
          .collection(DataField.collection)
          .document(globals.firebaseUser.uid)
          .collection(DataField.transaction)
          .document(widget.document.documentID);
      isEdit = true;
    } else {
      _mainReference = Firestore.instance
          .collection(DataField.collection)
          .document(globals.firebaseUser.uid)
          .collection(DataField.transaction)
          .document();
    }
    return Scaffold(
        appBar: AppBar(title: const Text('貸し借り入力'), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              print("保存ボタンを押しました．");
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _mainReference.setData({
                  DataField.borrowOrLend: _data.borrowOrLend,
                  DataField.user: _data.user,
                  DataField.stuff: _data.stuff,
                  DataField.date: _data.date
                });
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: !isEdit
                ? null
                : () {
                    print("削除ボタンを押しました．");
                    // 削除処理
                    _mainReference.delete();
                    Navigator.pop(context);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Share.share("[" +
                    (_data.borrowOrLend == "lend" ? "貸" : "借") +
                    "]" +
                    _data.stuff +
                    "\n期限：" +
                    globals.formatter.format(_data.date) +
                    "\n相手：" +
                    _data.user +
                    "\n#かしかりメモ");
              }
            },
          )
        ]),
        body: SafeArea(
            child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              RadioListTile(
                value: "borrow",
                groupValue: _data.borrowOrLend,
                title: Text("借りた"),
                onChanged: (String value) {
                  print("借りたをタッチしました．" + value);
                  _setBorrowOrLend(value);
                },
              ),
              RadioListTile(
                value: "lend",
                groupValue: _data.borrowOrLend,
                title: Text("貸した"),
                onChanged: (String value) {
                  print("貸したをタッチしました．" + value);
                  _setBorrowOrLend(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: '相手の名前',
                  labelText: 'Name',
                ),
                onSaved: (String value) {
                  _data.user = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return '名前は必須入力項目です．';
                  }
                },
                initialValue: _data.user,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.business_center),
                  hintText: '借りたもの，貸したもの',
                  labelText: 'loan',
                ),
                onSaved: (String value) {
                  _data.stuff = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return '借りたもの，貸したものは必須入力項目です．';
                  }
                },
                initialValue: _data.stuff,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("締め切り日:${globals.formatter.format(_data.date)}"),
              ),
              RaisedButton(
                child: const Text("締め切り日変更"),
                onPressed: () {
                  print("締切日変更をタッチしました．");
                  _selectTime(context).then((time) {
                    if (time != null && time != _data.date) {
                      setState(() {
                        _data.date = time;
                      });
                    }
                  });
                },
              )
            ],
          ),
        )));
  }
}
