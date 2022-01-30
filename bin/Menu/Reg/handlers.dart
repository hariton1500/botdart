import 'dart:io';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import '../../models.dart';
import '../../helper.dart';

regHandler(String text, TeleDart bot, int chatId, Abon abon,
    Map<String, Map<String, dynamic>> users) async {
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
          abon.menuLevel = 'accs';
          for (var guid in abon.guids!) {
            var res = await abon.getInfo(chatId, guid);
            if (!res['error']) {
              users[guid] = res['message']['userinfo'];
              bot.sendMessage(
                  chatId, '${users[guid]!['id']} - информация загружена');
            }
          }
          bot.sendMessage(chatId, mess['accs']! + menu['accs']!,
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBrief, btnFull],
                uidBtns(abon.guids!
                    .map((guid) => int.parse(users[guid]!['id'].toString()))
                    .toList()),
                [btnBack]
              ], resize_keyboard: true));
          break;
        case 'справочник абонента':
          bot.sendMessage(chatId, mess['info']! + menu['info']!,
              reply_markup: markups['help']);
          abon.menuLevel = 'help';
          break;
        default:
          bot.sendMessage(chatId, mess['not']! + menu['topIn']!,
              reply_markup: markups['topIn']);
      }
      break;
    case 'accs':
      switch (text) {
        case 'показать кратко':
          print('показать кратко');
          bot.sendMessage(chatId, abon.showUsersInfo(true, users));
          break;
        case 'показать подробно':
          bot.sendMessage(chatId, abon.showUsersInfo(false, users));
          break;
        case 'назад':
          abon.menuLevel = 'top';
          bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!,
              reply_markup: markups['topIn']);
          break;
        default:
          if (int.tryParse(text) != null) {
            print('text is digit');
            int id = int.parse(text);
            List<String> list = List.from(
                abon.guids!.map((guid) => users[guid]!['id']).toList());
            if (list.contains(id.toString())) {
              print('$id found in ${abon.showUsersInfo(true, users)}');
              abon.selectedId = id;
              abon.selectedGuid = abon.guids![list.indexOf(id.toString())];
              bot.sendMessage(chatId,
                  '${mess['id']}\n\n${abon.showUserInfo(users)}\n\n${menu['id']}',
                  reply_markup: markups['id']);
              abon.menuLevel = 'id';
            } else {
              print('$id not found in ${abon.showUsersInfo(true, users)}');
            }
          } else {
            print('text is not digit');
          }
      }
      break;
    case 'id':
      switch (text) {
        case 'сообщение с службу поддержки':
          bot.sendMessage(
              chatId, 'Введите текст сообщения для службы поддержки:',
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBack]
              ], resize_keyboard: true));
          abon.menuLevel = 'id_mess';
          break;
        case 'пополнить баланс':
          bot.sendMessage(chatId,
              'Введите сумму платежа, учтите, что платежная система берет комиссию 6%',
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBack]
              ], resize_keyboard: true));
          abon.menuLevel = 'id_sum';
          break;
        case 'назад':
          abon.menuLevel = 'accs';
          bot.sendMessage(chatId, mess['accs']! + menu['accs']!,
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBrief, btnFull],
                uidBtns(abon.guids!
                    .map((guid) => int.parse(users[guid]!['id'].toString()))
                    .toList()),
                [btnBack]
              ], resize_keyboard: true));
          break;
        default:
      }
      break;
    case 'id_mess':
      switch (text) {
        case 'назад':
          abon.menuLevel = 'id';
          bot.sendMessage(chatId,
              '${mess['id']}\n\n${abon.showUserInfo(users)}\n\n${menu['id']}',
              reply_markup: markups['id']);
          break;
        default:
          var res = await abon.sendRemont(abon.selectedGuid!, chatId, text);
          if (!res['error']) {
            bot.sendMessage(chatId, res['message']);
          }
          bot.sendMessage(chatId,
              '${mess['id']}\n\n${abon.showUserInfo(users)}\n\n${menu['id']}',
              reply_markup: markups['id']);
          abon.menuLevel = 'id';
      }
      break;
    case 'id_sum':
      switch (text) {
        case 'назад':
          abon.menuLevel = 'id';
          bot.sendMessage(chatId,
              '${mess['id']}\n\n${abon.showUserInfo(users)}\n\n${menu['id']}',
              reply_markup: markups['id']);
          break;
        default:
          if (int.tryParse(text) != null) {
            bot.sendMessage(chatId,
                'Для пополнения баланса учетной записи ${abon.selectedId} перейдите по ссылке:');
            var res = await abon.getPaymentId(abon.selectedGuid!, chatId);
            String url =
                'https://paymaster.ru/payment/init?LMI_MERCHANT_ID=95005d6e-a21d-492a-a4c5-c39773020dd3&LMI_PAYMENT_AMOUNT=' +
                    text.toString() +
                    '&LMI_CURRENCY=RUB&LMI_PAYMENT_NO=' +
                    res['message']['payment_id'].toString() +
                    '&LMI_PAYMENT_DESC=%D0%9F%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5%20EvpaNet%20ID%20' +
                    abon.selectedId.toString();
            bot.sendMessage(chatId, '[ПОПОЛНИТЬ БАЛАНС]($url)',
                parse_mode: 'markdown',
                reply_markup: ReplyKeyboardMarkup(keyboard: [
                  [btnBack]
                ]));
            abon.menuLevel = 'id';
          }
      }
      break;
    case 'help':
      switch (text) {
        case 'выбор WiFi роутера':
          bot.sendMessage(chatId, mess['choose_router']!);
          break;
        case 'список услуг компании EvpaNet':
          bot.sendMessage(chatId, mess['services']!);
          break;
        case 'способы оплаты':
          bot.sendMessage(chatId, answer['payVars']!,
              reply_markup: markups['help']);
          break;
        case 'назад':
          abon.menuLevel = 'top';
          bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!,
              reply_markup: markups['topIn']);
          break;
        default:
      }
      break;
    default:
  }
  print('out--> ' + abon.toString());
}

regHandler2(String text, Bot bot, int chatId, Abon abon,
    Map<String, Map<String, dynamic>> users) async {
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
          abon.menuLevel = 'accs';
          for (var guid in abon.guids!) {
            var res = await abon.getInfo(chatId, guid);
            if (!res['error']) {
              users[guid] = res['message']['userinfo'];
              //bot.sendMessage(chatId, '${users[guid]!['id']} - информация загружена/обновлена');
              //sleep(Duration(milliseconds: 300));
            }
          }
          bot.sendMessage(chatId, mess['accs']! + menu['accs']!,
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBrief, btnFull],
                uidBtns(abon.guids!
                    .map((guid) => int.parse(users[guid]!['id'].toString()))
                    .toList()),
                [btnBack]
              ], resize_keyboard: true));
          break;
        case 'справочник абонента':
          bot.sendMessage(chatId,
              'Добро пожаловать в справочную абонента. Выбор тем внизу экрана:',
              reply_markup: markups['help']);
          abon.menuLevel = 'help';
          break;
        default:
          bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!,
              reply_markup: markups['topIn']);
      }
      break;
    case 'accs':
      switch (text) {
        case 'показать кратко':
          print('показать кратко');
          bot.sendMessage(
              chatId, abon.showUsersInfo(true, users) + '\n\n' + menu['accs']!);
          //bot.sendMessage(chatId, menu['accs']!);
          break;
        case 'показать подробно':
          bot.sendMessage(
              chatId, abon.showUsersInfo(false, users) + '\n' + menu['accs']!);
          //bot.sendMessage(chatId, menu['accs']!);
          break;
        case 'назад':
          abon.menuLevel = 'top';
          bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!,
              reply_markup: markups['topIn']);
          break;
        default:
          if (int.tryParse(text) != null) {
            print('text is digit');
            int id = int.parse(text);
            List<String> list = List.from(
                abon.guids!.map((guid) => users[guid]!['id']).toList());
            if (list.contains(id.toString())) {
              print('$id found in ${abon.showUsersInfo(true, users)}');
              abon.selectedId = id;
              abon.selectedGuid = abon.guids![list.indexOf(id.toString())];
              bot.sendMessage(chatId,
                  '${mess['id']}\n\n${abon.showUserInfo(users)}\n\n${menu['id']}',
                  reply_markup: markups['id']);
              abon.menuLevel = 'id';
            } else {
              print('$id not found in ${abon.showUsersInfo(true, users)}');
              bot.sendMessage(
                  chatId, mess['wrongId']! + '\n\n' + menu['accs']!);
            }
          } else {
            print('text is not digit');
            bot.sendMessage(chatId, mess['not']! + menu['accs']!);
          }
      }
      break;
    case 'id':
      switch (text) {
        case 'сообщение в службу поддержки':
          bot.sendMessage(
              chatId, 'Введите текст сообщения для службы поддержки:',
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBack]
              ], resize_keyboard: true));
          abon.menuLevel = 'id_mess';
          break;
        case 'пополнить баланс':
          bot.sendMessage(chatId,
              'Введите сумму платежа, учтите, что платежная система берет комиссию 6%',
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBack]
              ], resize_keyboard: true));
          abon.menuLevel = 'id_sum';
          break;
        case 'вкл/выкл автоактивацию':
          var ress = await abon.sendAuto(abon.selectedGuid, chatId);
          if (!ress['error']) {
            var res = await abon.getInfo(chatId, abon.selectedGuid!);
            if (!res['error']) {
              users[abon.selectedGuid!] = res['message']['userinfo'];
            }
            bot.sendMessage(chatId,
                '${abon.showUserInfo(users)}\n\n${menu['id']}');
          }
          break;
        case 'вкл/выкл родительский контроль':
          var ress = await abon.sendParent(abon.selectedGuid, chatId);
          if (!ress['error']) {
            var res = await abon.getInfo(chatId, abon.selectedGuid!);
            if (!res['error']) {
              users[abon.selectedGuid!] = res['message']['userinfo'];
            }
            bot.sendMessage(chatId,
                '${abon.showUserInfo(users)}\n\n${menu['id']}');
          }
          break;
        case 'назад':
          abon.menuLevel = 'accs';
          bot.sendMessage(chatId, mess['accs']! + menu['accs']!,
              reply_markup: ReplyKeyboardMarkup(keyboard: [
                [btnBrief, btnFull],
                uidBtns(abon.guids!
                    .map((guid) => int.parse(users[guid]!['id'].toString()))
                    .toList()),
                [btnBack]
              ], resize_keyboard: true));
          break;
        default:
      }
      break;
    case 'id_mess':
      switch (text) {
        case 'назад':
          abon.menuLevel = 'id';
          bot.sendMessage(
              chatId, '${abon.showUserInfo(users)}\n\n${menu['id']}',
              reply_markup: markups['id']);
          break;
        default:
          var res = await abon.sendRemont(abon.selectedGuid!, chatId, text);
          if (!res['error']) {
            bot.sendMessage(chatId, res['message']);
          }
          bot.sendMessage(chatId,
              '${mess['id']}\n\n${abon.showUserInfo(users)}\n\n${menu['id']}',
              reply_markup: markups['id']);
          abon.menuLevel = 'id';
      }
      break;
    case 'id_sum':
      switch (text) {
        case 'назад':
          abon.menuLevel = 'id';
          bot.sendMessage(chatId,
              '${mess['id']}\n\n${abon.showUserInfo(users)}\n\n${menu['id']}',
              reply_markup: markups['id']);
          break;
        default:
          if (int.tryParse(text) != null) {
            bot.sendMessage(chatId,
                'Для пополнения баланса учетной записи ${abon.selectedId} перейдите по ссылке:');
            sleep(Duration(milliseconds: 500));
            var res = await abon.getPaymentId(abon.selectedGuid!, chatId);
            String url =
                'https://paymaster.ru/payment/init?LMI_MERCHANT_ID=95005d6e-a21d-492a-a4c5-c39773020dd3&LMI_PAYMENT_AMOUNT=' +
                    text.toString() +
                    '&LMI_CURRENCY=RUB&LMI_PAYMENT_NO=' +
                    res['message']['payment_id'].toString() +
                    '&LMI_PAYMENT_DESC=%D0%9F%D0%BE%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5%20EvpaNet%20ID%20' +
                    abon.selectedId.toString();
            bot.sendMessage(chatId, '[ПОПОЛНИТЬ БАЛАНС]($url)',
                parse_mode: 'markdown',
                reply_markup: ReplyKeyboardMarkup(keyboard: [
                  [btnBack]
                ], resize_keyboard: true));
            abon.menuLevel = 'id';
          }
      }
      break;
    case 'help':
      switch (text) {
        case 'выбор WiFi роутера':
          bot.sendMessage(chatId, mess['choose_router']!);
          break;
        case 'список услуг компании EvpaNet':
          bot.sendMessage(chatId, mess['services']!);
          break;
        case 'способы оплаты':
          bot.sendMessage(chatId, answer['payVars']!);
          break;
        case 'назад':
          abon.menuLevel = 'top';
          bot.sendMessage(chatId, mess['topIn']! + menu['topIn']!,
              reply_markup: markups['topIn']);
          break;
        default:
      }
      break;
    default:
  }
  print('out--> ' + abon.toString());
}
