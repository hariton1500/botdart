import 'package:teledart/model.dart';
import 'dart:io' as io;

var btnAbout = KeyboardButton(text: 'Описание');
var btnReg = KeyboardButton(text: 'Авторизация');
var btnShortly = KeyboardButton(text: 'Список ID (кратко)');
var btnId = KeyboardButton(text: 'Ввести ID');
var btnPhone = KeyboardButton(text: 'Ввести номер телефона');
var btnBack = KeyboardButton(text: 'Назад');
var btnAccs = KeyboardButton(text: 'Учетные записи');
var btnInfo = KeyboardButton(text: 'Полезная информация');

var options = {
  'back': 'Возврат/Отмена',
  'askId': 'Указать ID:',
  'askPhone': 'Указать номер телефона:',
  'reg': 'Авторизация',
  'about': 'Описание',
  'info': 'Полезная информация',
  'accs': 'Учетные записи',
};
var menu = {
  'reg':
      '1. ${options['askId']}\n2. ${options['askPhone']}\n3. ${options['back']}',
  'topIn': '1. ${options['accs']}\n2. ${options['info']}\n3. ${options['reg']}',
  'topNotIn': '1. ${options['reg']}\n2. ${options['about']}',
};

var mess = {
  'start':
      'Вас приветствует бот EvpaNet. С его помощью можно легко увидеть информацию о состоянии учетной записи, а еще, он будет присылать уведомления о скором окончании срока действия пакета интернет и другие оповещения.',
  'topIn': 'Главное меню:\n',
  'isReg':
      '\nДоступные команды:\n1. Авторизация - пройти новую авторизацию (для тех у кого много разных учетных записей)\n2. Показать учетные записи - отобразит краткий список учетных записей\n3. ID - покажет данные учетной записи более детально',
  'askId&Phone':
      'Вы перешли в меню идентификации учетных записей.\nВыбор команд:\n' +
          menu['reg']!,
  'askId': 'Введите ID:',
  'wrongId': 'Введите корректный ID:',
  'askPhone': 'Введите номер телефона:',
  'wrongPhone':
      'Введенный номер не корректный. Нужно вводить в фрмате +7ХХХХХХХХХХ. Повторите ввод'
};
var markups = {
  'topIn': ReplyKeyboardMarkup(keyboard: [
    [btnAccs, btnInfo, btnReg]
  ]),
  'topNotIn': ReplyKeyboardMarkup(keyboard: [
    [btnReg, btnAbout]
  ]),
  'empty': ReplyKeyboardRemove(remove_keyboard: true),
  'reg': ReplyKeyboardMarkup(keyboard: [
    [btnId, btnPhone, btnBack]
  ]),
};

Future<bool> ifRegistered(int chatId) async {
  var file = io.File('${chatId.toString()}.dat');
  return file.exists();
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
