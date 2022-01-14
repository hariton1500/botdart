import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const MODE_START = 0;
const REGID = 1;
const REGPHONE = 2;

class Abon {
  int? chatId;
  int? mode;
  int? uid;
  String? phone;
  List<String>? guids;

  Abon() {
    chatId = 0;
    mode = MODE_START;
    guids = [];
    //uid = 0;
  }

  Abon.loadOrCreate(int id) {
    var file = File('$chatId.dat');
    if (file.existsSync()) {
      guids = jsonDecode(file.readAsStringSync());
    } else {
      guids = [];
    }
    chatId = id;
    mode = MODE_START;
  }

  Future<Map<String, dynamic>> register() async {
    String apiUrl = 'https://evpanet.com/api/apk/login/user';
    var headers = {'token': chatId.toString()};
    var body = {'number': phone, 'uid': uid.toString()};
    var resp = await http.post(Uri.parse(apiUrl), body: body, headers: headers);
    return jsonDecode(resp.body);
  }

  Future<void> saveGuids() async {
    var file = File('$chatId.dat');
    file.writeAsString(guids.toString());
  }

  @override
  String toString() {
    return '[$chatId] mode=$mode guids=$guids';
  }
}
