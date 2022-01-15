import 'package:teledart/teledart.dart';
import '../../models.dart';
import '../../helper.dart';

regHandler(String text, TeleDart bot, int chatId, Abon abon) async {
  switch (abon.menuLevel) {
    case 'top':
      switch (text) {
        case 'авторизация':
          bot.sendMessage(chatId, mess['askId&Phone']!,
              reply_markup: markups['reg']);
          abon.menuLevel = 'askIdPhoneBack';
          abon.statusReg = false;
          break;
        default:
      }
      break;
    default:
  }
}
