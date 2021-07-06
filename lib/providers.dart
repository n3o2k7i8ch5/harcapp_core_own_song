
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_widgets/multi_text_field.dart';
import 'package:harcapp_core_own_song/song_raw.dart';
import 'package:harcapp_core_song/song_element.dart';

import 'common.dart';


class CurrentItemProvider extends ChangeNotifier{

  SongRaw? _song;

  late MultiTextFieldController authorsController;
  late MultiTextFieldController composersController;
  late MultiTextFieldController performersController;

  late TextEditingController ytLinkController;

  late MultiTextFieldController addPersController;


  void _updateControllers(SongRaw song){
    authorsController.texts = song.authors;
    composersController.texts = song.composers;
    performersController.texts = song.performers;

    ytLinkController.text = song.youtubeLink??'';

    addPersController.texts = song.addPers;
  }

  CurrentItemProvider({SongRaw? song}){
    _song = song;

    authorsController = MultiTextFieldController(texts: song?.authors);
    composersController = MultiTextFieldController(texts: song?.composers);
    performersController = MultiTextFieldController(texts: song?.performers);

    ytLinkController = TextEditingController(text: song?.youtubeLink??'');

    addPersController = MultiTextFieldController(texts: song?.addPers);

  }

  SongRaw? get song => _song;
  set song(SongRaw? value){
    _song = value;
    if(song != null) _updateControllers(_song!);
    notifyListeners();
  }

  set fileName(String value){
    _song!.fileName = value;
    notifyListeners();
  }

  set title(String value){
    _song!.title = value;
    notifyListeners();
  }

  set authors(List<String> value){
    _song!.authors = value;
    notifyListeners();
  }

  set composers(List<String> value){
    _song!.composers = value;
    notifyListeners();
  }

  set performers(List<String> value){
    _song!.performers = value;
    notifyListeners();
  }

  DateTime? get releaseDate => _song!.releaseDate;
  set releaseDate(DateTime? value){
    _song!.releaseDate = value;
    notifyListeners();
  }

  bool get showRelDateMonth => _song!.showRelDateMonth;
  set showRelDateMonth(bool value){
    _song!.showRelDateMonth = value;
    notifyListeners();
  }

  bool get showRelDateDay => _song!.showRelDateDay;
  set showRelDateDay(bool value){
    _song!.showRelDateDay = value;
    notifyListeners();
  }

  String? get youtubeLink => _song!.youtubeLink;
  set youtubeLink(String? value){
    _song!.youtubeLink = value;
    notifyListeners();
  }

  List<String> get addPers => _song!.addPers;
  set addPers(List<String> value){
    _song!.addPers = value;
    notifyListeners();
  }

  set tags(List<String> value){
    _song!.tags = value;
    notifyListeners();
  }

  bool get hasRefren => _song!.hasRefren;
  set hasRefren(bool value){
    _song!.hasRefren = value;
    notifyListeners();
  }

  removePart(SongPart part){
    _song!.songParts!.remove(part);
    notifyListeners();
  }
  addPart(SongPart part){
    _song!.songParts!.add(part);
    notifyListeners();
  }

  void notify() => notifyListeners();

}

class HidTitlesProvider extends ChangeNotifier{

  List<TextEditingController>? _controllers;
  late bool _isLastEmpty;

  HidTitlesProvider({List<String>? hidTitles}){
    if(hidTitles == null)
      _controllers = [];
    else
      _controllers = hidTitles.map((hidTitle) => TextEditingController(text: hidTitle)).toList();

    _isLastEmpty = hidTitles==null || (hidTitles.length > 0 && hidTitles.last.length==0);
  }

  void add({String? hidTitle, Function()? onChanged}){
    TextEditingController controller = TextEditingController(text: hidTitle??'');
    _isLastEmpty = controller.text.length==0;
    controller.addListener(() {
      if(controller == _controllers!.last){

        if(controller.text.length==0 && !_isLastEmpty)
          notifyListeners();
        else if(controller.text.length!=0 && _isLastEmpty)
          notifyListeners();

        _isLastEmpty = controller.text.length==0;
      }
    });

    if(onChanged != null)
      controller.addListener(onChanged);

    _controllers!.add(controller);

    notifyListeners();
  }

  void remove(TextEditingController controller){
    _controllers!.remove(controller);
    _isLastEmpty = controllers!.isEmpty || controllers!.last.text.length==0;
    notifyListeners();
  }

  List<String> get() => _controllers!.map((ctrl) => ctrl.text).toList();

  bool get isLastEmpty => !hasAny?true:_controllers!.last.text.length==0;

  bool get hasAny => _controllers!.length != 0;

  List<TextEditingController>? get controllers => _controllers;

}

class TextShiftProvider extends ChangeNotifier{

  late bool _shifted;
  void Function(bool)? onChanged;

  TextShiftProvider({required bool shifted, this.onChanged}){
    _shifted = shifted;
  }

  bool get shifted => _shifted;
  set shifted(bool value){
    _shifted = value;
    onChanged?.call(_shifted);
    notifyListeners();
  }

  void reverseShift(){
    _shifted = !_shifted;
    onChanged?.call(_shifted);
    notifyListeners();
  }

}

/*
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

  static isChordMissing(String text, String chords) => text.length>0 && (chords.length==0);

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
*/
class RefrenEnabProvider extends ChangeNotifier{

  bool? _refEnab;

  RefrenEnabProvider(bool refEnab){
    _refEnab = refEnab;
  }

  bool? get refEnab => _refEnab;

  set refEnab(bool? value){
    _refEnab = value;
    notifyListeners();
  }

}

class RefrenPartProvider extends ChangeNotifier{
/*
  RefrenPartProvider(SongPart part):super(part);

  String get chords => part.chords;
  set chords(String value){
    part.chords = value;
    notifyListeners();
  }

  String getText() => part.getText();
  void setText(String text) => part.setText(text);

  void clear({bool notify: true}){
    _part = SongPart.empty(isRefrenTemplate: true);
    if(notify) notifyListeners();
  }

  bool isRefren(SongElement element) => element == part.element;

  SongElement get element => part.element;
  bool get isError => part.isError;
*/
  void notify() => notifyListeners();

}

class TagsProvider extends ChangeNotifier{
  List<String>? _checkedTags;

  TagsProvider(List<String> allTags, List<String> checkedTags){
    _checkedTags = checkedTags;
  }

  set(List<String> allTags, List<String> checkedTags){
    _checkedTags = checkedTags;
    notifyListeners();
  }

  String get(int idx) => _checkedTags![idx];

  void add(String tag){
    if(!_checkedTags!.contains(tag)) {
      _checkedTags!.add(tag);
      _checkedTags!.sort();
    }
    notifyListeners();
  }

  void remove(String tag){
    _checkedTags!.remove(tag);
    notifyListeners();
  }

  List<String>? get checkedTags => _checkedTags;

  int get count => _checkedTags!.length;
}

class TitleCtrlProvider extends ChangeNotifier{
  TextEditingController? controller;
  TitleCtrlProvider({String? text, Function(String text)? onChanged}){
    controller = TextEditingController(text: text);
    if(onChanged!=null) controller!.addListener(() => onChanged(controller!.text));
  }

  set text(String value){
    controller!.text = value;
    notifyListeners();
  }
}

class SongPartProvider extends ChangeNotifier{

  SongPart _part;
  SongPartProvider(this._part);

  SongPart get part => _part;
  set part(SongPart part){
    _part = part;
    notifyListeners();
  }

  void notify() => notifyListeners();

}