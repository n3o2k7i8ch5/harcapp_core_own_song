import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common.dart';
import 'providers.dart';

const int MAX_CHORDS_IN_LINE = 8;
const int MAX_TEXT_LINE_LENGTH = 52;

isChordMissing(String text, String chords) => text != null && text.length>0 && (chords == null || chords.length==0);

int handleErrors(BuildContext context, bool isRefren){

  int errCount = 0;

  ErrorProvider<ChordsMissingError> chordsMissingErrProv = Provider.of<ErrorProvider<ChordsMissingError>>(context, listen: false);
  errCount += ChordsMissingError.handleErrors(context, chordsMissingErrProv);

  ErrorProvider<TextTooLongError> textTooLongErrProv = Provider.of<ErrorProvider<TextTooLongError>>(context, listen: false);
  errCount += TextTooLongError.handleErrors(context, textTooLongErrProv);

  return errCount;
}

class ErrorProvider<T extends SongEditError> extends ChangeNotifier{

  List<T> _error_list;
  Map<int, T> _error_map;

  ErrorProvider({Function(ErrorProvider<T> errProv) init}){
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

  T errorAt(int line){
    return _error_map[line];
  }

  void notify() => notifyListeners();
}

abstract class SongEditError{

  final int line;
  final Color color;
  final String text;

  const SongEditError({
    this.line,
    @required this.color,
    @required this.text
  });

}

class ChordsMissingError extends SongEditError{

  ChordsMissingError({int line}): super(
    line: line,
    color: COLOR_WAR,
    text: 'Każda linijka tekstu, której akompniuje instrument wymaga podania chwytów.'
  );

  static int handleErrors(BuildContext context, ErrorProvider<ChordsMissingError> errProv){

    List<String> textLines = Provider.of<TextProvider>(context, listen: false).text.split('\n');
    List<String> chordLines = Provider.of<ChordsProvider>(context, listen: false).chords.split('\n');

    errProv.clear();
    for(int i=0; i<textLines.length; i++)
      if (isChordMissing(textLines[i], i < chordLines.length ? chordLines[i] : null))
        errProv.add(ChordsMissingError(line: i));

    errProv.notify();
    return errProv.length;
  }

  static bool hasError(String text, String chords){

    List<String> textLines = text.split('\n');
    List<String> chordsLines = chords.split('\n');

    for(int i=0; i<textLines.length; i++)
      if (isChordMissing(textLines[i], i < chordsLines.length ? chordsLines[i] : null))
        return true;

    return false;
  }

}

class TextTooLongError extends SongEditError{

  TextTooLongError({int line}): super(
      line: line,
      color: COLOR_ERR,
      text: 'Linijka tekstu nie powinna przekraczać $MAX_TEXT_LINE_LENGTH znaków.'
  );

  static int handleErrors(BuildContext context, ErrorProvider<TextTooLongError> errProv){

    List<String> textLines = Provider.of<TextProvider>(context, listen: false).text.split('\n');

    errProv.clear();
    for(int i=0; i<textLines.length; i++)
      if(textLines[i].length>MAX_TEXT_LINE_LENGTH)
        errProv.add(TextTooLongError(line: i));

    return errProv.length;

  }

  static bool hasError(String text, String chords){

    List<String> textLines = text.split('\n');

    for(int i=0; i<textLines.length; i++)
      if(textLines[i].length>MAX_TEXT_LINE_LENGTH)
        return true;

    return false;
  }
}

class AnyError extends StatelessWidget{

  final Widget Function(BuildContext context, int errCont) builder;

  const AnyError({@required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<ErrorProvider<ChordsMissingError>>(builder: (context, chordsMissingErrProv, child) =>
        Consumer<ErrorProvider<TextTooLongError>>(builder: (context, textTooLongErrProv, child) =>
          builder(
            context,
            chordsMissingErrProv.length + textTooLongErrProv.length
          )
        ),
    );
  }

}

bool hasAnyErrors(String text, String chords){
  return ChordsMissingError.hasError(text, chords) || TextTooLongError.hasError(text, chords);
}