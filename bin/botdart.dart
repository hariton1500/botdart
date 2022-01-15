import 'dart:io';

//import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'Menu/UnReg/handlers.dart';
import 'helper.dart';
import 'models.dart';

Future<void> main(List<String> arguments) async {
  print('EvpaNet help bot');

  var token = '5074469034:AAEfZA-kiuBPS840S66Fj2v7kJs_wKLe1QQ';

  final username = (await Telegram(token).getMe()).username;

  int readedMessageId = 2050;
  bool isRegistered = false;

  var teledart = TeleDart(token, Event(username!));

  var mesStream = teledart.onMessage();
  var commandStartStream = teledart.onCommand('start');
  //var m = Data();
  Map<String, Abon> abons = {};

  commandStartStream.listen((commMess) async {
    isRegistered = await ifRegistered(commMess.chat.id);
    if (!isRegistered) {
      teledart.sendMessage(commMess.chat.id, mess['start']!,
          reply_markup: markups['startMurkups']!);
    } else {
      teledart.sendMessage(commMess.chat.id, mess['isReg']!);
    }
  });

  Future<void> messageHandler(DateTime date, int chatId, String text) async {
    text = text.toLowerCase();
    print(abons[chatId.toString()]!.toString());
    if (text.contains('stop')) {
      print('exiting on stop command');
      teledart.stop();
      exit(1);
    }
    var statusReg = abons[chatId.toString()]!.statusReg;
    switch (statusReg) {
      case true:
        //regHandler();
        break;
      case false:
        unregHandler(text, teledart, chatId, abons[chatId.toString()]!);
        break;
      default:
    }
  }

  mesStream.listen((message) {
    int currentMessId = message.message_id;
    print(currentMessId);
    if (currentMessId != readedMessageId) {
      readedMessageId = currentMessId;
      var date = DateTime.now();
      if (message.text != null) {
        int chatId = message.chat.id;
        String text = message.text!;
        print('[$date] ($chatId) $text');
        if (!abons.containsKey(chatId.toString())) {
          abons[chatId.toString()] = Abon.loadOrCreate(chatId);
        }
        messageHandler(date, chatId, text);
      }
    }
  });

  teledart.start();
}
