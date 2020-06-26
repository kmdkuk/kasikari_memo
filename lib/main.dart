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
    return Scaffold(
        appBar: AppBar(title: const Text('貸し借り入力'), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              print("保存ボタンを押しました．");
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              print("削除ボタンを押しました．");
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
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.business_center),
                  hintText: '借りたもの，貸したもの',
                  labelText: 'loan',
                ),
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
          stream: Firestore.instance.collection('kasikari-memo').snapshots(),
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
                  builder: (BuildContext context) => InputForm()),
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
                (document['borrowOrLend'] == "lend" ? "貸" : "借") +
                "]" +
                document['stuff']),
            subtitle: Text('期限: ' +
                DateFormat.yMMMd('ja').format(document['date'].toDate()) +
                "\n相手: " +
                document['user']),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text("編集"),
                onPressed: () {
                  print("編集ボタンを押しました．");
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
