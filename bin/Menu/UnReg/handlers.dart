import 'package:teledart/teledart.dart';
import '../../models.dart';
import '../../helper.dart';

unregHandler(String text, TeleDart bot, int chatId, Abon abon) async {
  switch (abon.menuLevel) {
    case 'top':
      switch (text) {
        case 'авторизация':
          bot.sendMessage(chatId, mess['askId&Phone']! + menu['reg']!,
              reply_markup: markups['reg']);
          abon.menuLevel = 'askIdPhoneBack';
          break;
        case 'описание':
          bot.sendMessage(chatId, mess['itCan']! + mess['about']!, reply_markup: markups['topNotIn']);
          break;
        default:
          //bot.sendMessage(chatId, menu[abon.statusReg! ? 'topIn' : 'topNotIn']!, reply_markup: markups[abon.statusReg! ? 'topIn' : 'topNotIn']);
      }
      break;
    case 'askIdPhoneBack':
      switch (text) {
        case 'ввести id':
          bot.sendMessage(chatId, 'Введите ID:',
              reply_markup: markups['empty']);
          abon.menuLevel = 'enterId';
          break;
        case 'ввести номер телефона':
          bot.sendMessage(chatId,
              'Введите номер телефона в формате +########### без пробелов и скобок:',
              reply_markup: markups['empty']);
          abon.menuLevel = 'enterPhone';
          break;
        case 'назад':
          abon.statusReg = abon.guids!.isNotEmpty;
          abon.menuLevel = 'top';
          bot.sendMessage(chatId, mess['start']! + mess['itCan']! + mess['about']! + menu[abon.statusReg! ? 'topIn' : 'topNotIn']!,
              reply_markup: markups[abon.statusReg! ? 'topIn' : 'topNotIn']);
          break;
        default:
      }
      break;
    case 'enterId':
      if (int.tryParse(text) != null) {
        abon.uid = int.parse(text);
        abon.menuLevel = 'askIdPhoneBack';
        bot.sendMessage(chatId, 'ID сохранен');
        //sleep(Duration(seconds: 1));
        //bot.sendMessage(chatId, mess['askId&Phone']!, reply_markup: markups['reg']);
        if (abon.phone != null && abon.phone!.isNotEmpty) {
          var resp = await abon.register();
          if (!resp['error']) {
            abon.guids = List.from(resp['message']['guids']);
            abon.saveGuids();
            abon.menuLevel = 'top';
            abon.statusReg = true;
            bot.sendMessage(chatId, 'Авторизация прошла успешно');
            bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!,
                reply_markup: markups['topIn']);
          } else {
            abon.menuLevel = 'askIdPhoneBack';
            bot.sendMessage(chatId, 'ИНФО: ' + resp['message'] + '\nПроверьте правильность введенных данных:\n' +  '\nID: ${abon.uid}\nНомер телефона: ${abon.phone}' '\n\n' + menu['reg']!,
                reply_markup: markups['reg']);
          }
        } else {
          bot.sendMessage(chatId, 'ID: ${abon.uid}\nНомер телефона: ${abon.phone != null ? abon.phone! : 'еще не указан'}' '\n'  + menu['reg']!, reply_markup: markups['reg']);
        }
      } else {
        bot.sendMessage(chatId, mess['wrongId']!);
      }
      break;
    case 'enterPhone':
      if (isPhone(text)) {
        abon.phone = text;
        abon.menuLevel = 'askIdPhoneBack';
        //sleep(Duration(seconds: 1));
        bot.sendMessage(chatId, 'Номер телефона сохранен');
        //bot.sendMessage(chatId, mess['askId&Phone']!, reply_markup: markups['reg']);
        if (abon.uid != null && abon.uid! > 0) {
          var resp = await abon.register();
          if (!resp['error']) {
            abon.guids = List.from(resp['message']['guids']);
            abon.saveGuids();
            abon.menuLevel = 'top';
            abon.statusReg = true;
            bot.sendMessage(chatId, 'Авторизация прошла успешно');
            bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!,
                reply_markup: markups['topIn']);
          } else {
            abon.menuLevel = 'askIdPhoneBack';
            bot.sendMessage(chatId, 'ИНФО: ' + resp['message'] + '\nПроверьте правильность введенных данных:\n' +  '\nID: ${abon.uid}\nНомер телефона: ${abon.phone}' '\n\n' + menu['reg']!,
                reply_markup: markups['reg']);
          }
        } else {
          bot.sendMessage(chatId, 'ID: ${abon.uid}\nНомер телефона: ${abon.phone != null ? abon.phone! : 'еще не указан'}' '\n' + menu['reg']!, reply_markup: markups['reg']);
        }
      } else {
        bot.sendMessage(chatId, mess['wrongPhone']!);
      }
      break;
    default:
  }
  print('out--> ' + abon.toString());
}
