import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'splash.dart';
import 'list.dart';

void main() {
  initializeDateFormatting('ja');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かしかりメモ',
      routes: <String, WidgetBuilder>{
        '/': (_) => Splash(),
        '/list': (_) => List(),
      },
    );
  }
}
