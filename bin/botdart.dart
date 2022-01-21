import 'dart:io';

//import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'Menu/Reg/handlers.dart';
import 'Menu/UnReg/handlers.dart';
import 'helper.dart';
import 'models.dart';

Future<void> main(List<String> arguments) async {
  print('EvpaNet help bot');

  var token = '5074469034:AAEfZA-kiuBPS840S66Fj2v7kJs_wKLe1QQ';

  final username = (await Telegram(token).getMe()).username;

  int readedMessageId = 2369;
  bool isRegistered = false;

  var teledart = TeleDart(token, Event(username!));

  var mesStream = teledart.onMessage(entityType: '*');
  var commandStartStream = teledart.onCommand('start');
  //var m = Data();
  Map<String, Abon> abons = {};
  Map<String, Map<String, dynamic>> users = {};

  commandStartStream.listen((commMess) async {
    isRegistered = await isChatRegistered(commMess.chat.id);
    if (!isRegistered) {
      String chatId = commMess.chat.id.toString();
      if (abons.containsKey(chatId)) {
        abons.remove(chatId);
      }
      teledart.sendMessage(commMess.chat.id, mess['start']! + menu['topNotIn']!,
          reply_markup: markups['topNotIn']!);
    } else {
      teledart.sendMessage(commMess.chat.id, mess['isReg']! + menu['topIn']!);
    }
  });

  Future<void> messageHandler(DateTime date, int chatId, String text) async {
    text = text.toLowerCase();
    //print('[$date] ($chatId) $text');
    print('in <$text>' + abons[chatId.toString()]!.toString());
    if (text.contains('stop')) {
      print('exiting on stop command');
      await teledart.sendMessage(chatId, 'Остановка бота',
          reply_markup: markups['empty']);
      teledart.stop();
      exit(1);
    }
    var statusReg = abons[chatId.toString()]!.statusReg;
    switch (statusReg) {
      case true:
        regHandler(text, teledart, chatId, abons[chatId.toString()]!, users);
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
        //print('[$date] ($chatId) $text');
        if (!abons.containsKey(chatId.toString())) {
          abons[chatId.toString()] = Abon.loadOrCreate(chatId);
        }
        messageHandler(date, chatId, text);
      }
    }
  });

  teledart.start();
}
