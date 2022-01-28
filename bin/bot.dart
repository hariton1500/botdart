import 'dart:async';
import 'dart:io';

import 'Menu/Reg/handlers.dart';
import 'Menu/UnReg/handlers.dart';
import 'helper.dart';
import 'models.dart';

void main(List<String> args) {
  print('dart bot v2 start...');
  var token = '5074469034:AAEfZA-kiuBPS840S66Fj2v7kJs_wKLe1QQ';

  Bot teledart = Bot(token: token);

  Map<String, Abon> abons = {};
  Map<String, Map<String, dynamic>> users = {};

  Future<void> messageHandler(int chatId, String text) async {
    text = text.toLowerCase();
    //print('[$date] ($chatId) $text');
    print('in <$text>' + abons[chatId.toString()]!.toString());
    /*
    if (text.contains('stop')) {
      print('exiting on stop command');
      teledart.sendMessage(chatId, 'Остановка бота...',
          reply_markup: markups['empty']);
      sleep(Duration(seconds: 1));
      exit(1);
    }*/
    var statusReg = abons[chatId.toString()]!.statusReg;
    switch (statusReg) {
      case true:
        regHandler2(text, teledart, chatId, abons[chatId.toString()]!, users);
        break;
      case false:
        unregHandler2(text, teledart, chatId, abons[chatId.toString()]!);
        break;
      default:
    }
  }

  Timer.periodic(Duration(milliseconds: 500), (timer) {
    var update = teledart.getUpdate();
    update.then((message) async {
      if (message is Map) {
        if (message['ok']) {
          var results = message['result'];
          for (var result in results) {
            print(result);
            teledart.updateId = result['update_id'];
            String chatId = result['message']['chat']['id'].toString();
            String text = result['message']['text'].toString();
            if (text.contains('start')) {
              bool isRegistered = await isChatRegistered(teledart.chatId!);
              if (!isRegistered) {
                String chatId = teledart.chatId.toString();
                if (abons.containsKey(chatId)) {
                  abons.remove(chatId);
                }
                teledart.sendMessage(
                    int.parse(chatId),
                    mess['start']! +
                        mess['itCan']! +
                        mess['about']! +
                        menu['topNotIn']!,
                    reply_markup: markups['topNotIn']!);
              } else {
                teledart.sendMessage(
                    int.parse(chatId), mess['isReg']! + menu['topIn']!);
              }
            } else {
              if (!abons.containsKey(chatId.toString())) {
                abons[chatId.toString()] = Abon.loadOrCreate(int.parse(chatId));
              }
              messageHandler(int.parse(chatId), text);
            }
          }
        }
      }
    });
  });
}
