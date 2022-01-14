import 'dart:io';

//import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'helper.dart';
import 'models.dart';

Future<void> main(List<String> arguments) async {
  print('EvpaNet help bot');

  var token = '5074469034:AAEfZA-kiuBPS840S66Fj2v7kJs_wKLe1QQ';

  final username = (await Telegram(token).getMe()).username;

  int readedMessageId = 2028;
  bool isRegistered = false;

  var teledart = TeleDart(token, Event(username!));

  var mesStream = teledart.onMessage();
  var commandStartStream = teledart.onCommand('start');
  var m = Data();
  Map<String, Abon> abons = {};

  commandStartStream.listen((commMess) async {
    //print('command handler:');
    //print(commMess.text);
    //print(commMess.message_id);
    //int chId = commMess.chat.id;
    isRegistered = await m.ifRegistered(commMess.chat.id);
    if (!isRegistered) {
      teledart.sendMessage(commMess.chat.id, m.mess['start']!,
          reply_markup: m.markups['startMurkups']!);
    } else {
      teledart.sendMessage(commMess.chat.id, m.mess['isReg']!);
    }
  });

  Future<void> messageHandler(DateTime date, int chatId, String text) async {
    text = text.toLowerCase();
    if (!abons.containsKey(chatId.toString())) {
      abons[chatId.toString()] = Abon.loadOrCreate(chatId);
    }
    print(abons[chatId.toString()]!.toString());
    if (text.contains('stop')) {
      print('exiting on stop command');
      teledart.stop();
      exit(1);
    }
    if (text.contains('start')) {
      print(text);
    }
    if (text.contains('авторизация')) {
      teledart.sendMessage(chatId, m.mess['askId']!,
          reply_markup: m.markups['empty']);
      abons[chatId.toString()]!.mode = REGID;
    }
    if (abons.containsKey(chatId.toString()) &&
        abons[chatId.toString()]!.mode == REGID) {
      if (int.tryParse(text) != null) {
        abons[chatId.toString()]!.uid = int.parse(text);
        abons[chatId.toString()]!.mode = REGPHONE;
        teledart.sendMessage(chatId, m.mess['askPhone']!);
      }
    }
    if (abons.containsKey(chatId.toString()) &&
        abons[chatId.toString()]!.mode == REGPHONE) {
      if (isPhone(text)) {
        print('text is phone');
        abons[chatId.toString()]!.phone = text;
        var resp = await abons[chatId.toString()]!.register();
        if (!resp['error']) {
          abons[chatId.toString()]!.guids = resp['message']['guids'];
          abons[chatId.toString()]!.saveGuids();
        }
      } else {
        print('text is not a phone');
        teledart.sendMessage(chatId, m.mess['wrongPhone']!);
      }
    }
  }

  mesStream.listen((message) {
    int currentMessId = message.message_id;
    print(currentMessId);
    //exit(2);
    if (currentMessId != readedMessageId) {
      readedMessageId = currentMessId;
      //shared.setInt('readedMessageId', currentMessId);
      var date = DateTime.now();
      if (message.text != null) {
        int chatId = message.chat.id;
        String text = message.text!;
        //print(message.date_);
        print('[$date] ($chatId) $text');
        messageHandler(date, chatId, text);
      } else {
        teledart.stop();
        exit(0);
      }
    }
  });

  teledart.start();
}
