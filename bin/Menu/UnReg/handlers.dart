import 'package:teledart/teledart.dart';
import '../../models.dart';
import '../../helper.dart';

unregHandler(String text, TeleDart bot, int chatId, Abon abon) async {
  switch (abon.menuLevel) {
    case 'top':
      switch (text) {
        case 'авторизация':
          bot.sendMessage(chatId, mess['askId&Phone']!,
              reply_markup: markups['reg']);
          abon.menuLevel = 'askIdPhoneBack';
          break;
        case 'информация':
          break;
        default:
      }
      break;
    case 'askIdPhoneBack':
      switch (text) {
        case 'ввести id':
          bot.sendMessage(chatId, 'Ввдите ID:', reply_markup: markups['empty']);
          abon.menuLevel = 'enterId';
          break;
        case 'ввести номер телефона':
          bot.sendMessage(
              chatId, 'Введите номер телефона в формате +###########:');
          abon.menuLevel = 'enterPhone';
          break;
        default:
      }
      break;
    case 'enterId':
      if (int.tryParse(text) != null) {
        abon.uid = int.parse(text);
        abon.menuLevel = 'askIdPhoneBack';
        bot.sendMessage(chatId, 'ID сохранен');
        bot.sendMessage(chatId, mess['askId&Phone']!,
            reply_markup: markups['reg']);
        if (abon.phone != null && abon.phone!.isNotEmpty) {
          var resp = await abon.register();
          if (!resp['error']) {
            abon.guids = resp['message']['guids'];
            abon.saveGuids();
            abon.menuLevel = 'top';
            abon.statusReg = true;
          }
        }
      }
      break;
    case 'enterPhone':
      if (isPhone(text)) {
        abon.phone = text;
        abon.menuLevel = 'askIdPhoneBack';
        bot.sendMessage(chatId, 'Номер телефона сохранен');
        bot.sendMessage(chatId, mess['askId&Phone']!,
            reply_markup: markups['reg']);
        if (abon.uid != null && abon.uid! > 0) {
          var resp = await abon.register();
          if (!resp['error']) {
            abon.guids = resp['message']['guids'];
            abon.saveGuids();
            abon.menuLevel = 'top';
            abon.statusReg = true;
          }
        }
      }
      break;
    default:
  }
}
