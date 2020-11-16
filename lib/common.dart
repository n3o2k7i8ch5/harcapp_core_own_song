

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_classes/primitive_wrapper.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_own_song/providers.dart';
import 'package:harcapp_core_song/song_element.dart';
import 'package:provider/provider.dart';

import 'errors.dart';

const double CHORDS_WIDGET_MIN_WIDTH = 80.0;

Color COLOR_OK = Colors.green.withOpacity(0.5);
Color COLOR_WAR = Colors.red.withOpacity(0.3);
Color COLOR_ERR = Colors.red.withOpacity(0.7);

TextInputFormatter ALLOWED_TEXT_REGEXP = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9ĄąĆćĘęŁłŃńÓóŚśŹźŻż \(\)\-\.\,\!\?\n]'));


class HeaderWidget extends StatelessWidget{

  final String title;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  const HeaderWidget(this.title, this.icon, {this.iconColor, this.enabled: true});

  @override
  Widget build(BuildContext context) {

    Color color = iconColor;
    if(color==null){
      color = enabled?textEnabled(context):hintEnabled(context);
    }

    return Padding(
      padding: EdgeInsets.all(2*Dimen.DEF_MARG),
      child: Row(
        children: [
          SizedBox(height: Dimen.ICON_FOOTPRINT),
          Icon(icon, color: color),
          SizedBox(width: Dimen.LIST_TILE_SEPARATOR),
          Text(title,
            style: AppTextStyle(
                color: enabled?textEnabled(context):hintEnabled(context),
                fontWeight: weight.halfBold,
                fontSize: Dimen.TEXT_SIZE_BIG,
                shadow: enabled
            ),
          ),
        ],
      ),
    );
  }

}

class SongPart{

  final SongElement _songElement;
  final PrimitiveWrapper<bool> _isError;

  String getText({bool withTabs: false}) => _songElement.getText(withTabs: withTabs);
  void setText(String text) => _songElement.setText(text);

  SongElement get element => _songElement;

  String get chords => _songElement.chords;
  set chords(String text) => _songElement.chords = text;

  bool get shift => _songElement.shift;
  set shift(bool value) => _songElement.shift = value;

  bool get isEmpty => chords.length==0 && getText().length==0;

  SongPart copy() => SongPart.from(
    element.copy(),
  );

  static SongPart from(SongElement songElement){
    return SongPart(
        songElement,
        PrimitiveWrapper<bool>(hasAnyErrors(songElement.getText(), songElement.chords))
    );
  }

  static empty({isRefrenTemplate: false}){
    return SongPart.from(SongElement.empty(isRefrenTemplate: isRefrenTemplate));
  }

  SongPart(this._songElement, this._isError);

  bool get isError => _isError.get();
  set isError(bool value) => _isError.set(value);

  bool isRefren(BuildContext context){
    RefrenPartProvider prov = Provider.of<RefrenPartProvider>(context, listen: false);
    return prov.isRefren(element);
  }

}