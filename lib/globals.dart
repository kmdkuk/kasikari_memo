library kasikari_memo.globals;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

FirebaseUser firebaseUser;
final FirebaseAuth auth = FirebaseAuth.instance;

DateFormat formatter = DateFormat.yMMMd('ja');
