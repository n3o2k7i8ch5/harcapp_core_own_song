
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/title_show_row_widget.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:provider/provider.dart';

import '../providers.dart';
import '../song_part_card.dart';


class RefrenTemplate extends StatelessWidget{

  final Function()? onPartTap;
  final Function(bool value)? onRefrenEnabledChanged;
  final Color? accentColor;

  const RefrenTemplate({this.onPartTap, this.onRefrenEnabledChanged, this.accentColor});

  @override
  Widget build(BuildContext context) {

    return Consumer2<CurrentItemProvider, RefrenPartProvider>(
        builder: (context, currItemProv, refProv, child) => Padding(
          padding: EdgeInsets.only(left: Dimen.DEF_MARG, right: Dimen.DEF_MARG),
          child: SongPartCard.from(
            songPart: currItemProv.song.refrenPart,
            type: SongPartType.REFREN_TEMPLATE,
            topBuilder: (context, part) => Padding(
              padding: EdgeInsets.only(left: Dimen.ICON_MARG - Dimen.DEF_MARG),
              child: Consumer<CurrentItemProvider>(
                builder: (context, currItemProv, child) => TitleShortcutRowWidget(
                  title: 'Szablon refrenu',
                  titleColor:
                  currItemProv.song.refrenPart.isError?
                  Colors.red:
                  (currItemProv.hasRefren?textEnab_(context):textDisab_(context)),
                  textAlign: TextAlign.start,
                  trailing: Switch(
                    value: currItemProv.hasRefren,
                    onChanged: (bool value){
                      currItemProv.hasRefren = !currItemProv.hasRefren;
                      if(onRefrenEnabledChanged != null) onRefrenEnabledChanged!(value);
                    },
                    activeColor: accentColor??accent_(context),
                  ),
                ),
              ),
            ),
            onTap: () => onPartTap?.call(),
          ),
        ),
    );
  }
}