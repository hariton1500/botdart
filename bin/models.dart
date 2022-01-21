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
  //Map<String, Map<String, dynamic>>? users;
  int? selectedId;
  String? selectedGuid;

  Abon.loadOrCreate(int id) {
    //users = {};
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

  String showUsersInfo(bool brief, Map<String, Map<String, dynamic>> users) {
    if (brief) {
      return guids!.map((guid) => users[guid]!['id']).toList().toString();
    } else {
      return guids!
          .map((guid) {
            selectedGuid = guid;
            selectedId = int.parse(users[guid]!['id'].toString());
            return showUserInfo(users) + '\n';
          })
          .toList()
          .toString();
    }
  }

  String showUserInfo(Map<String, Map<String, dynamic>> users) {
    Map<String, dynamic> user = users[selectedGuid]!;
    String name = user['name'];
    double balance = double.parse(user['extra_account']);
    //login = user['login'];
    //password = user['clear_pass'];
    int daysRemain = (int.parse(user['packet_secs']) / 60 / 60 / 24).round();
    String endDate = user['packet_end'] ?? '00.00.0000 00:00';
    double debt = double.parse(user['debt'] ?? 0.0);
    String tarifName = user['tarif_name'];
    int tarifSum = int.parse(user['tarif_sum'].toString());
    String ip = user['real_ip'];
    String street = user['street'];
    String house = user['house'];
    String flat = user['flat'];
    bool auto = user['auto_activation'] == '1';
    bool parentControl = user['flag_parent_control'] == '1';
    //print(user['allowed_tarifs']);
    //tarifs.addAll(user['allowed_tarifs']);
    //String dayPrice = user['days_price'];
    return 'ID: $selectedId\n'
            'ФИО: $name\n'
            'Баланс: $balance руб.\n'
            'Задолжность: $debt руб.\n'
            'Дата окончания срока действия пакета: $endDate. Осталось дней: $daysRemain\n'
            'Тариф: $tarifName ($tarifSum руб.)\n'
            'Адрес: $street д. $house кв. $flat\n'
            'IP адрес: $ip\n'
            'Авто активация: ' +
        (auto ? 'Да\n' : 'Нет\n') +
        'Родительский контроль: ' +
        (parentControl ? 'Да\n' : 'Нет\n');
  }

  Future<Map<String, dynamic>> getPaymentId(String guid, int chatId) async {
    String apiUrl = 'https://evpanet.com/api/apk/payment';
    var headers = {'token': chatId.toString()};
    var body = {'guid': guid};
    var resp = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
    return jsonDecode(resp.body);
  }

  Future<Map<String, dynamic>> sendRemont(guid, chatId, text) async {
    String apiUrl = 'https://evpanet.com/api/apk/support/request';
    var headers = {'token': chatId.toString()};
    var body = {'message': text, 'guid': guid};
    var resp = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
    return jsonDecode(resp.body);
  }

  @override
  String toString() {
    return '[$chatId] menu={$statusReg}$menuLevel guids=${guids!.length}';
  }
}
