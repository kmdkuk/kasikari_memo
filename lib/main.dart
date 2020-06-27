import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  initializeDateFormatting('ja');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かしかりメモ',
      home: List(),
    );
  }
}

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

class _DataField {
  static final String collection = 'kasikari-memo';
  static final String borrowOrLend = 'borrowOrLend';
  static final String user = 'user';
  static final String stuff = 'stuff';
  static final String date = 'date';
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
    DocumentReference _mainReference =
        Firestore.instance.collection(_DataField.collection).document();
    bool isEdit = false;
    if (widget.document != null) {
      if (_data.user == null && _data.stuff == null) {
        _data.borrowOrLend = widget.document[_DataField.borrowOrLend];
        _data.user = widget.document[_DataField.user];
        _data.stuff = widget.document[_DataField.stuff];
        _data.date = widget.document[_DataField.date].toDate();
      }
      _mainReference = Firestore.instance
          .collection(_DataField.collection)
          .document(widget.document.documentID);
      isEdit = true;
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
                  _DataField.borrowOrLend: _data.borrowOrLend,
                  _DataField.user: _data.user,
                  _DataField.stuff: _data.stuff,
                  _DataField.date: _data.date
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
                child:
                    Text("締め切り日:${DateFormat.yMMMd('ja').format(_data.date)}"),
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

class List extends StatefulWidget {
  @override
  _MyList createState() => _MyList();
}

class _MyList extends State<List> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト画面"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              Firestore.instance.collection(_DataField.collection).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 10.0),
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            print("新規作成ボタンを押しました．");
            Navigator.push(
              context,
              MaterialPageRoute(
                  settings: const RouteSettings(name: "/new"),
                  builder: (BuildContext context) => InputForm(null)),
            );
          }),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.android),
            title: Text("[" +
                (document[_DataField.borrowOrLend] == "lend" ? "貸" : "借") +
                "]" +
                document[_DataField.stuff]),
            subtitle: Text('期限: ' +
                DateFormat.yMMMd('ja')
                    .format(document[_DataField.date].toDate()) +
                "\n相手: " +
                document[_DataField.user]),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text("編集"),
                onPressed: () {
                  print("編集ボタンを押しました．");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          settings: const RouteSettings(name: '/edit'),
                          builder: (BuildContext context) =>
                              InputForm(document)));
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
