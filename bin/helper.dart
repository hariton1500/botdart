import 'package:teledart/model.dart';
import 'dart:io' as io;

var btnAbout = KeyboardButton(text: 'Описание');
var btnReg = KeyboardButton(text: 'Авторизация');
var btnShortly = KeyboardButton(text: 'Список ID (кратко)');
var btnId = KeyboardButton(text: 'Ввести ID');
var btnPhone = KeyboardButton(text: 'Ввести номер телефона');
var btnBack = KeyboardButton(text: 'Назад');
var btnAccs = KeyboardButton(text: 'Учетные записи');
var btnInfo = KeyboardButton(text: 'Справочник абонента');
var btnBrief = KeyboardButton(text: 'Показать кратко');
var btnFull = KeyboardButton(text: 'Показать подробно');
var btnPay = KeyboardButton(text: 'Пополнить баланс');
var btnMess = KeyboardButton(text: 'Сообщение в службу поддержки');
var btnChR = KeyboardButton(text: 'Выбор WiFi роутера');
var btnList = KeyboardButton(text: 'Список услуг компании EvpaNet');
var btnPayVars = KeyboardButton(text: 'Способы оплаты');

var options = {
  'back': btnBack.text,
  'askId': btnId.text,
  'askPhone': btnPhone.text,
  'reg': btnReg.text,
  'about': btnAbout.text,
  'info': btnInfo.text,
  'accs': btnAccs.text,
  'brief': btnBrief.text,
  'full': btnFull.text,
  'pay': btnPay.text,
  'mess': btnMess.text,
};
var menu = {
  'reg':
      '1. ${options['askId']}\n2. ${options['askPhone']}\n3. ${options['back']}',
  'topIn': '1. ${options['accs']}\n2. ${options['info']}\n3. ${options['reg']}',
  'topNotIn': '1. ${options['reg']}\n2. ${options['about']}',
  'accs':
      '1. ${options['brief']}\n2. ${options['full']}\n3. ID - Меню управления учетной записью\n4. ${options['back']}',
  'id': '1. ${options['pay']}\n2. ${options['mess']}\n3. ${options['back']}',
};

var mess = {
  'start':
      'Вас приветствует бот EvpaNet.',
  'itCan': '\n\nБот умеет:\n  -  Управлять учетными записями (в т.ч. онлайн пополнение баланса)\n  -  Уведомлять о скором окончании срока действия пакета интернет\n  -  Содержит справочник полезной информации',
  'about': '\n\nВ первую очередь Вам надо пройти авторизацию. Бот запомнит Вас и список Ваших учетных записей.\nДля управления ботом нужно вводить команды, на которые он запрограммирован. Для удобства все доступные команды представлены кнопками внизу экрана.\nСписок команд в этом разделе меню следующий:\n',
  'topIn': 'Главное меню:\n',
  'isReg':
      '\nДоступные команды:\n1. Авторизация - пройти новую авторизацию (для тех у кого много разных учетных записей)\n2. Показать учетные записи - отобразит краткий список учетных записей\n3. ID - покажет данные учетной записи более детально',
  'askId&Phone':
      'Вы перешли в меню идентификации учетных записей.\n\nБоту нужно сообщить номер телефона и любой из ID, за которым закреплен этот номер телефона. Внимание: Внести ID или номер телефона можно только после соответствующей команды.\n\nВыбор команд:\n',
  'askId': 'Введите ID:',
  'wrongId': 'Введите корректный ID:',
  'askPhone': 'Введите номер телефона:',
  'wrongPhone':
      'Введенный номер не корректный. Нужно вводить в фрмате +7ХХХХХХХХХХ. Повторите ввод',
  'accs': 'Вы перешли в раздел управления учетными записями\n',
  'id': 'Вы перешли в раздел управления учетной записью',
};
var markups = {
  'topIn': ReplyKeyboardMarkup(keyboard: [
    [btnAccs, btnInfo],
    [btnReg]
  ], resize_keyboard: true),
  'topNotIn': ReplyKeyboardMarkup(keyboard: [
    [btnReg, btnAbout]
  ], resize_keyboard: true),
  'empty': ReplyKeyboardRemove(remove_keyboard: true),
  'reg': ReplyKeyboardMarkup(keyboard: [
    [btnId, btnPhone],
    [btnBack]
  ], resize_keyboard: true),
  'accs': ReplyKeyboardMarkup(keyboard: [
    [btnBrief, btnFull],
    [btnBack]
  ], resize_keyboard: true),
  'id': ReplyKeyboardMarkup(keyboard: [
    [btnPay, btnMess],
    [btnBack]
  ], resize_keyboard: true),
  'help': ReplyKeyboardMarkup(keyboard: [
    [btnPayVars, btnList],
    [btnChR, btnBack]
  ], resize_keyboard: true),
};

Future<bool> isChatRegistered(int chatId) async {
  var file = io.File('${chatId.toString()}.dat');
  return file.exists();
}

List<KeyboardButton> uidBtns(List<int> uids) {
  return uids.map((uid) => KeyboardButton(text: uid.toString())).toList();
}

bool isPhone(String text) {
  /*
  String pattern = r'^(?:[+][1-9])?[0-9]{10,12}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(text);*/
  return text.startsWith('+') &&
      text.substring(1).length == 11 &&
      int.tryParse(text.substring(1)) != null;
}
