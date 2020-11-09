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
    this.performer = song.performer;
    this.addPers = song.addPers;
    this.youtubeLink = song.youtubeLink;
    this.tags = song.tags?.toList();

    this.hasRefren = song.hasRefren;
    this.refrenPart = song.refrenPart?.copy();

    this.songParts = song.songParts;
  }

  SongRaw({
    this.fileName,
    this.title,
    this.hidTitles,
    this.author,
    this.performer,
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
      performer: '',
      addPers: '',
      youtubeLink: '',
      tags: [],
      hasRefren: true,
      refrenPart: SongPart.empty(isRefren: true),
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

    String title = map['title'];
    List<String> hidTitles = (map['hid_titles'] as List).cast<String>();
    String author = map['text_author'];
    String performer = map['performer'];
    String youtubeLink = map['yt_link'];
    String addPers = map['add_pers'];
    List<String> tags = (map['tags'] as List).cast<String>();
    SongPart refrenPart;
    if (map.containsKey('refren')) {
      hasRefren = true;
      Map refrenMap = map['refren'];
      refrenPart = SongPart.from(SongElement.from(refrenMap['text'], refrenMap['chords'], true));
    }

    List<SongPart> songParts = [];
    List<dynamic> partsList = map['parts'];
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
      performer: performer,
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
    String performer,
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
      performer: performer??this.performer,
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
    map['title'] = title;
    map['hid_titles'] = hidTitles;
    map['text_author'] = author;
    map['performer'] = performer;
    map['yt_link'] = youtubeLink;
    map['add_pers'] = addPers;

    map['tags'] = tags;

    if(hasRefren && refrenPart != null && !refrenPart.isEmpty)
      map['refren'] = {
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

          if (part.element != refrenPart?.element) {
            parts.add({
              'text': part.getText(),
              'chords': part.chords,
              'shift': part.shift
            });
          }
        }
    }

    if(hasRefren && refCount>0)
      parts.add({'refren': refCount});

    map['parts'] = parts;

    if(withFileName) return {fileName : map};
    else return map;
  }

  String toCode(){
    return jsonEncode(toMap());
  }

  @override
  int get rate => 0; //SongRate.RATE_NULL;

/*
  static Future<SongRaw> read({@required String fileName}) async {
    String code = await getSongCode(fileName);
    return SongRaw.parse(fileName, code);
  }
*/
}





