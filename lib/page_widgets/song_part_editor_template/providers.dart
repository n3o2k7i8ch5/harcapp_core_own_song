import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'errors.dart';

class TextProvider extends ChangeNotifier{

  late TextEditingController controller;

  TextProvider({String text = ''}){
    controller = TextEditingController(text: text);
  }

  String get text => controller.text;
  set text(String value){
    controller.text = value;
    notifyListeners();
  }

}

class ChordsProvider extends ChangeNotifier{

  late TextEditingController controller;

  ChordsProvider({String chords = ''}){
    controller = TextEditingController(text: chords);
  }

  String get chords => controller.text;
  set chords(String value){
    controller.text = value;
    notifyListeners();
  }

}

class ErrorProvider<T extends SongEditError> extends ChangeNotifier{

  late List<T> _error_list;
  late Map<int?, T> _error_map;

  ErrorProvider({Function(ErrorProvider<T> errProv)? init}){
    _error_list = [];
    _error_map = {};

    if(init != null) init(this);
  }

  void add(T error){
    _error_list.add(error);
    _error_map[error.line] = error;
  }

  int get length => _error_list.length;

  void clear(){
    _error_list.clear();
    _error_map.clear();
  }

  T? errorAt(int line){
    return _error_map[line];
  }

  void notify() => notifyListeners();
}
