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
  Map<String, Map<String, dynamic>>? users;
  int? selectedId;

  Abon.loadOrCreate(int id) {
    users = {};
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

  Future<Map<String, dynamic>> getInfo(int chatId, String guid) async {
    print('start get abon info for $guid');
    String apiUrl = 'https://evpanet.com/api/apk/user/info/' + guid;
    var headers = {'token': chatId.toString()};
    var resp = await http.get(Uri.parse(apiUrl), headers: headers);
    return jsonDecode(resp.body);
  }

  String showUsersInfo(bool brief) {
    if (brief) {
      return guids!.map((guid) => users![guid]!['id']).toList().toString();
    } else {
      return '';
    }
  }

  String showUserInfo(int id) {
    var info = users!.values.firstWhere((user) => user['id'].toString() == id.toString());
    return 'ID: ${info['id']}\nФИО: ${info['name']}\nБаланс: ${info['extra_account']} руб.\nДата окончания срока действия пакета: ${info['packet_end']}\nТариф: ${info['tarif_name']} (${info['tarif_sum']} руб.)';
  }

  @override
  String toString() {
    return '[$chatId] menu=$menuLevel[$menuTopic]{$statusReg} guids=${guids!.length}';
  }
}
