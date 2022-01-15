import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Abon {
  int? chatId;
  String? menuLevel;
  String? menuTopic;
  int? uid;
  String? phone;
  List<String>? guids;
  bool? statusReg;

  Abon.loadOrCreate(int id) {
    var file = File('$id.dat');
    if (file.existsSync()) {
      print('file exists');
      guids = List.from(jsonDecode(file.readAsStringSync()));
      statusReg = true;
    } else {
      print('file is not exists');
      guids = [];
      statusReg = false;
    }
    chatId = id;
    menuLevel = 'top';
    menuTopic = '';
  }

  Future<Map<String, dynamic>> register() async {
    print('start register');
    String apiUrl = 'https://evpanet.com/api/apk/login/user';
    var headers = {'token': chatId.toString()};
    var body = {'number': phone, 'uid': uid.toString()};
    var resp = await http.post(Uri.parse(apiUrl), body: body, headers: headers);
    return jsonDecode(resp.body);
  }

  Future<void> saveGuids() async {
    var file = File('$chatId.dat');
    file.writeAsString(jsonEncode(guids));
  }

  @override
  String toString() {
    return '[$chatId] menu=$menuLevel[$menuTopic]{$statusReg} guids=${guids!.length}';
  }
}
