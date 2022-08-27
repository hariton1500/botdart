// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:teledart/model.dart' as m;

class Bot {
  String? url;
  int? updateId;
  int? chatId;
  String? text;

  Bot({required String token}) {
    url = 'https://api.telegram.org/bot$token/';
  }

  // ignore: non_constant_identifier_names
  void sendMessage(int chatId, String text,
      {String? parse_mode, m.ReplyMarkup? reply_markup}) {
    Map<String, String> _body = {'chat_id': chatId.toString(), 'text': text};
    String _url = url!;
    //var _headers = {'chat_id': chatId, 'text': text};
    _url += '?chat_id=$chatId&text=$text';
    if (parse_mode != null) {
      _body['parse_mode'] = parse_mode;
      _url += '&parse_mode=$parse_mode';
    }
    if (reply_markup != null) {
      _body['reply_markup'] = jsonEncode(reply_markup);
      _url += '&reply_markup=${reply_markup.toString()}';
    }
    _url = url! + 'sendMessage';
    //print('posting to:$_url with body: $_body');
    //http.get(Uri.parse(_url), headers: _body);
    http.post(Uri.parse(_url), body: _body);
  }

  Future<dynamic> getUpdate() async {
    String _url = url! + 'getUpdates';
    if (updateId != null) {
      _url += '?offset=${updateId! + 1}';
    }
    try {
      var resp = await http.get(Uri.parse(_url));
      return jsonDecode(resp.body);
    } catch (e) {
      print(e);
    }
  }

  void stop() {}
}

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
    var file = File('guids/$id.dat');
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
    print('requestUrl = $apiUrl; headers = $headers; body = $body');
    var resp = await http.post(Uri.parse(apiUrl), body: body, headers: headers);
    return jsonDecode(resp.body);
  }

  Future<void> saveGuids() async {
    var file = File('guids/$chatId.dat');
    await file.create(recursive: true);
    file.writeAsString(jsonEncode(guids));
  }

  Future<Map<String, dynamic>> getInfo(int chatId, String guid) async {
    print('start get abon info for $guid');
    String apiUrl = 'https://evpanet.com/api/apk/user/info/' + guid;
    var headers = {'token': chatId.toString()};
    print('requestUrl = $apiUrl; headers = $headers');
    var resp = await http.get(Uri.parse(apiUrl), headers: headers);
    return jsonDecode(resp.body);
  }

  String showUsersInfo(bool brief, Map<String, Map<String, dynamic>> users) {
    if (brief) {
      return guids!.map((guid) => users[guid]!['id']).toList().toString();
    } else {
      String list = '';
      for (var guid in guids!) {
        selectedGuid = guid;
        selectedId = int.parse(users[guid]!['id'].toString());
        list += showUserInfo(users) + '\n';
      }
      return list;
    }
  }

  String showUserInfo(Map<String, Map<String, dynamic>> users) {
    Map<String, dynamic> user = users[selectedGuid]!;
    String name = user['name'];
    double balance = double.parse(user['extra_account']);
    //login = user['login'];
    //password = user['clear_pass'];
    int daysRemain = 0;
    int hoursRemain = 0;
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
    String remainText = '';
    try {
      if (int.parse(user['packet_secs']) >= 0) {
        remainText = 'Осталось';
        daysRemain = (int.parse(user['packet_secs']) / 60 / 60 / 24).floor();
        hoursRemain = (int.parse(user['packet_secs']) / 60 / 60 % daysRemain).floor();
      } else {
        remainText = 'Просрочено';
        daysRemain = (int.parse(user['packet_secs']).abs() / 60 / 60 / 24).floor();
        hoursRemain = (int.parse(user['packet_secs']).abs() / 60 / 60 % daysRemain).floor();
      }
    } catch (e) {
      print(e);
    }
    return 'ID: $selectedId\n'
            'ФИО: $name\n'
            'Баланс: $balance руб.\n'
            'Задолжность: $debt руб.\n'
            'Дата окончания срока действия пакета: $endDate. $remainText: $daysRemain дн. $hoursRemain ч.\n'
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

  Future<Map<String, dynamic>> sendAuto(guid, chatId) async {
    String apiUrl = 'https://evpanet.com/api/apk/user/auto_activation/';
    var headers = {'token': chatId.toString()};
    var body = {'guid': guid};
    var resp = await http.put(Uri.parse(apiUrl), headers: headers, body: body);
    return jsonDecode(resp.body);
  }

  Future<Map<String, dynamic>> sendParent(guid, chatId) async {
    String apiUrl = 'https://evpanet.com/api/apk/user/parent_control/';
    var headers = {'token': chatId.toString()};
    var body = {'guid': guid};
    var resp = await http.put(Uri.parse(apiUrl), headers: headers, body: body);
    return jsonDecode(resp.body);
  }

  @override
  String toString() {
    return '[$chatId] menu={$statusReg}$menuLevel guids=${guids!.length}';
  }
}
