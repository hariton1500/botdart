import 'package:teledart/model.dart';
import 'dart:io' as io;

var btnAbout = KeyboardButton(text: 'Описание');
var btnReg = KeyboardButton(text: 'Авторизация');
var btnShortly = KeyboardButton(text: 'Список ID (кратко)');
var btnId = KeyboardButton(text: 'Ввести ID');

var startM = ReplyKeyboardMarkup(keyboard: [
  [btnAbout, btnReg]
]);

class Data {
  var mess = {
    'start':
        'Вас приветствует бот EvpaNet. С его помощью можно легко увидеть информацию о состоянии учетной записи, а еще, он будет присылать уведомления о скором окончании срока действия пакета интернет и другие оповещения.',
    'isReg':
        '\nДоступные команды:\n1. Авторизация - пройти новую авторизацию (для тех у кого много разных учетных записей)\n2. Показать учетные записи - отобразит краткий список учетных записей\n3. ID - покажет данные учетной записи более детально',
    'askId': 'Введите ID:',
    'askPhone': 'Введите номер телефона:',
    'wrongPhone':
        'Введенный номер не корректный. Нужно вводить в фрмате +7ХХХХХХХХХХ. Повторите ввод'
  };
  var markups = {
    'startMurkups': startM,
    'empty': ReplyKeyboardRemove(remove_keyboard: true)
  };

  Future<bool> ifRegistered(int chatId) async {
    var file = io.File('${chatId.toString()}.dat');
    return file.exists();
  }
}

bool isPhone(String text) {
  String pattern = r'^(?:[+][1-9])?[0-9]{10,12}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(text);
}
