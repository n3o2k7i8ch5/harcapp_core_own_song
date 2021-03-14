import 'dart:convert';

import 'package:harcapp_core_song/song_core.dart';
import 'package:harcapp_core_song/song_element.dart';

import 'common.dart';


class SongRaw implements SongCore{

  String fileName;
  String title;
  List<String> hidTitles;
  String author;
  String performer;
  String composer;
  DateTime releaseDate;
  bool showRelDateMonth;
  bool showRelDateDay;
  String addPers;
  String youtubeLink;

  bool get isOwn => !isOfficial && !isConfid;

  bool get isConfid => fileName.length >= 4 && fileName.substring(0, 4) == 'oc!_';
  bool get isOfficial => fileName.length >= 3 && fileName.substring(0, 3) == 'o!_';

  List<String> tags;

  bool hasRefren;
  SongPart refrenPart;

  List<SongPart> songParts;

  bool get hasChords => chords.replaceAll('\n', '').replaceAll(' ', '').length!=0;

  void set(SongRaw song){
    this.fileName = song.fileName;
    this.title = song.title;
    this.hidTitles = song.hidTitles;
    this.author = song.author;
    this.composer = song.composer;
    this.performer = song.performer;
    this.releaseDate = song.releaseDate;
    this.showRelDateMonth = song.showRelDateMonth;
    this.showRelDateDay = song.showRelDateDay;
    this.addPers = song.addPers;
    this.youtubeLink = song.youtubeLink;
    this.tags = song.tags?.toList();

    this.hasRefren = song.hasRefren??SongPart.empty(isRefrenTemplate: true);
    this.refrenPart = song.refrenPart?.copy();

    this.songParts = song.songParts;
  }

  SongRaw({
    this.fileName,
    this.title,
    this.hidTitles,
    this.author,
    this.composer,
    this.performer,
    this.releaseDate,
    this.showRelDateMonth,
    this.showRelDateDay,
    this.addPers,
    this.youtubeLink,

    this.tags,

    this.hasRefren,
    this.refrenPart,

    this.songParts,
  });

  static SongRaw empty({fileName: ''}){

    return SongRaw(
      fileName: fileName,
      title: '',
      hidTitles: [],
      author: '',
      composer: '',
      performer: '',
      releaseDate: null,
      showRelDateMonth: true,
      showRelDateDay: true,
      addPers: '',
      youtubeLink: '',
      tags: [],
      hasRefren: true,
      refrenPart: SongPart.empty(isRefrenTemplate: true),
      songParts: [],
    );
  }

  static SongRaw parse(String fileName, String code) {
    Map<String, dynamic> map = jsonDecode(code)[fileName];
    return fromMap(fileName, map);
  }

  static SongRaw from(String fileName, String codeBase64){
    String code = Utf8Decoder().convert(Base64Codec().decode(codeBase64).toList());
    return SongRaw.parse(fileName, code);
  }

  static SongRaw fromMap(String fileName, Map map){
    bool hasRefren = false;

    String title = map[SongCore.PARAM_TITLE];
    List<String> hidTitles = (map[SongCore.PARAM_HID_TITLES] as List).cast<String>();
    String author = map[SongCore.PARAM_TEXT_AUTHOR]??'';
    String composer = map[SongCore.PARAM_COMPOSER]??'';
    String performer = map[SongCore.PARAM_PERFORMER]??'';
    DateTime releaseDate = DateTime.tryParse(map[SongCore.PARAM_REL_DATE]??'');
    bool showRelDateMonth = map[SongCore.PARAM_SHOW_REL_DATE_MONTH]??true;
    bool showRelDateDay = map[SongCore.PARAM_SHOW_REL_DATE_DAY]??true;
    String youtubeLink = map[SongCore.PARAM_YT_LINK]??'';
    String addPers = map[SongCore.PARAM_ADD_PERS]??'';
    List<String> tags = (map[SongCore.PARAM_TAGS] as List).cast<String>();
    SongPart refrenPart;
    if (map.containsKey(SongCore.PARAM_REFREN)) {
      hasRefren = true;
      Map refrenMap = map[SongCore.PARAM_REFREN];
      refrenPart = SongPart.from(SongElement.from(refrenMap['text'], refrenMap['chords'], true));
    }else{
      refrenPart = SongPart.empty(isRefrenTemplate: true);
    }

    List<SongPart> songParts = [];
    List<dynamic> partsList = map[SongCore.PARAM_PARTS];
    for (Map partMap in partsList) {
      if (partMap.containsKey('refren'))
        for (int i = 0; i < partMap['refren']; i++) {
          songParts.add(SongPart.from(refrenPart.element));

        }
      else {
        SongPart songPart = SongPart.from(SongElement.from(partMap['text'], partMap['chords'], partMap['shift']));
        songParts.add(songPart);

      }
    }

    return SongRaw(
      fileName: fileName,
      title: title,
      hidTitles: hidTitles,
      author: author,
      composer: composer,
      performer: performer,
      releaseDate: releaseDate,
      showRelDateMonth: showRelDateMonth,
      showRelDateDay: showRelDateDay,

      addPers: addPers,
      youtubeLink: youtubeLink,

      tags: tags,

      hasRefren: hasRefren,
      refrenPart: refrenPart,

      songParts: songParts,
    );
  }

  SongRaw copyWith({
    String fileName,
    String title,
    List<String> hidTitles,
    String author,
    String composer,
    String performer,
    DateTime releaseDate,
    bool showRelDateMonth,
    bool showRelDateDay,
    String addPers,
    String youtubeLink,
    List<String> tags,
    String hasRefren,
    SongPart refrenPart,
    List<SongPart> songParts,
  }) => SongRaw(
      fileName: fileName??this.fileName,
      title: title??this.title,
      hidTitles: hidTitles??this.hidTitles,
      author: author??this.author,
      composer: composer??this.composer,
      performer: performer??this.performer,
      releaseDate: releaseDate??this.releaseDate,
      showRelDateMonth: showRelDateMonth??this.showRelDateMonth,
      showRelDateDay: showRelDateDay??this.showRelDateDay,
      addPers: addPers??this.addPers,
      youtubeLink: youtubeLink??this.youtubeLink,
      tags: tags??this.tags,
      hasRefren: hasRefren??this.hasRefren,
      refrenPart: refrenPart??this.refrenPart,
      songParts: songParts??this.songParts,
    );

  String get text{

    String text = '';

    for (SongPart part in songParts) {

      if(!hasRefren && part.element == refrenPart?.element)
        continue;

      text += part.getText(withTabs: part.shift);

      int textLines =  part.getText(withTabs: part.shift).split("\n").length;
      int chodsLines = part.chords.split("\n").length;

      for(int j=0; j<chodsLines-textLines; j++)
        text += '\n';

      text += '\n\n';
    }

    if(text.length>0) text = text.substring(0, text.length-2);

    return text;
  }

  String get chords{

    String chords = '';

    for (SongPart part in songParts) {

      if(!hasRefren && part.element == refrenPart?.element)
        continue;

      chords += part.chords;

      int textLines =  part.getText(withTabs: part.shift).split("\n").length;
      int chodsLines = part.chords.split("\n").length;

      for(int j=0; j<textLines-chodsLines; j++)
        chords += '\n';

      chords += '\n\n';
    }

    if(chords.length>0) chords = chords.substring(0, chords.length-2);

    return chords;
  }

  Map toMap({bool withFileName: true}){

    Map map = {};
    map[SongCore.PARAM_TITLE] = title;
    map[SongCore.PARAM_HID_TITLES] = hidTitles;
    map[SongCore.PARAM_TEXT_AUTHOR] = author;
    map[SongCore.PARAM_COMPOSER] = composer;
    map[SongCore.PARAM_PERFORMER] = performer;
    map[SongCore.PARAM_REL_DATE] = releaseDate?.toIso8601String();
    map[SongCore.PARAM_SHOW_REL_DATE_MONTH] = showRelDateMonth;
    map[SongCore.PARAM_SHOW_REL_DATE_DAY] = showRelDateDay;
    map[SongCore.PARAM_YT_LINK] = youtubeLink;
    map[SongCore.PARAM_ADD_PERS] = addPers;

    map[SongCore.PARAM_TAGS] = tags;

    hasRefren = hasRefren && refrenPart != null && !refrenPart.isEmpty;

    if(hasRefren)
      map[SongCore.PARAM_REFREN] = {
        'text': refrenPart.getText(),
        'chords': refrenPart.chords,
        'shift': true
      };

    List<Map> parts = [];

    int refCount = 0;
    for (SongPart part in songParts) {

      if(part.element == refrenPart?.element) {
          refCount++;
      } else {

          if (hasRefren && refCount > 0) {
            parts.add({'refren': refCount});
            refCount = 0;
          }

          parts.add({
            'text': part.getText(),
            'chords': part.chords,
            'shift': part.shift
          });
        }
    }

    if(hasRefren && refCount>0)
      parts.add({'refren': refCount});

    map[SongCore.PARAM_PARTS] = parts;

    if(withFileName) return {fileName : map};
    else return map;
  }

  String toCode({bool withFileName: true}) => jsonEncode(toMap(withFileName: withFileName));

  @override
  int get rate => 0; //SongRate.RATE_NULL;

/*
  static Future<SongRaw> read({@required String fileName}) async {
    String code = await getSongCode(fileName);
    return SongRaw.parse(fileName, code);
  }
*/
}





