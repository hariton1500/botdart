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
        case 'учетные записи':
          bot.sendMessage(chatId, mess['accs']! + menu['accs']!, reply_markup: markups['accs']);
          abon.menuLevel = 'accs';
          for (var guid in abon.guids!) {
            var res = await abon.getInfo(chatId, guid);
            if (!res['error']) {
              abon.users![guid] = res['message']['userinfo'];
              bot.sendMessage(chatId, '${abon.users![guid]!['id']} - информация загружена');
            }
          }
          break;
        default:
          bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!, reply_markup: markups['topIn']);
      }
      break;
    case 'accs':
      switch (text) {
        case 'показать кратко':
          print('показать кратко');
          bot.sendMessage(chatId, abon.showUsersInfo(true));
          break;
        case 'показать подробно':
          
          break;
        case 'назад':
          abon.menuLevel = 'top';
          bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!, reply_markup: markups['topIn']);
          break;
        default:
          if (int.tryParse(text) != null) {
            print('text is digit');
            int id = int.parse(text);
            List<String> list = List.from(abon.guids!.map((guid) => abon.users![guid]!['id']).toList());
            if (list.contains(id.toString())) {
              print('$id found in ${abon.showUsersInfo(true)}');
              bot.sendMessage(chatId, '${mess['id']}\n\n${abon.showUserInfo(id)}\n\n${menu['id']}', reply_markup: markups['id']);
              abon.selectedId = id;
              abon.menuLevel = 'id';
            } else {
              print('$id not found in ${abon.showUsersInfo(true)}');
            }
          } else {
            print('text is not digit');
          }
      }
      break;
    case 'id':
      switch (text) {
        case 'назад':
          abon.menuLevel = 'accs';
          bot.sendMessage(chatId, mess['accs']! + menu['accs']!, reply_markup: markups['accs']);
          break;
        default:
      }
      break;
    default:
  }
  print('out--> ' + abon.toString());
}
