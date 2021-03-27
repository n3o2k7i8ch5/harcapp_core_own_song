
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/title_show_row_widget.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:provider/provider.dart';

import '../common.dart';
import '../providers.dart';
import '../song_part_card.dart';


class RefrenTemplate extends StatelessWidget{

  final Function(SongPart, RefrenPartProvider) onPartTap;
  final Function(bool value) onRefrenEnabledChaned;
  final Color accentColor;

  const RefrenTemplate({this.onPartTap, this.onRefrenEnabledChaned, this.accentColor});

  @override
  Widget build(BuildContext context) {

    return Consumer<RefrenPartProvider>(
        builder: (context, prov, child) => Padding(
          padding: EdgeInsets.only(left: Dimen.DEF_MARG, right: Dimen.DEF_MARG),
          child: SongPartCard.from(
            songPart: prov.part,
            type: SongPartType.REFREN_TEMPLATE,
            topBuilder: (context, part) => Padding(
              padding: EdgeInsets.only(left: Dimen.ICON_MARG - Dimen.DEF_MARG),
              child: Consumer<CurrentItemProvider>(
                builder: (context, currItemProv, child) => TitleShortcutRowWidget(
                  title: 'Szablon refrenu',
                  //icon: prov.isError?MdiIcons.alertOutline:MdiIcons.musicBoxOutline,
                  titleColor:
                  prov.isError?
                  Colors.red:
                  (currItemProv.hasRefren?textEnab_(context):textDisab_(context)),
                  //titleColor: currItemProv.hasRefren?textEnab_(context):hintEnab_(context),
                  textAlign: TextAlign.start,
                  trailing: Switch(
                    value: currItemProv.hasRefren,
                    onChanged: (bool value){
                      currItemProv.hasRefren = !currItemProv.hasRefren;
                      if(onRefrenEnabledChaned != null) onRefrenEnabledChaned(value);
                    },
                    activeColor: accentColor??accent_(context),
                  ),
                ),
              ),
            ),
            onTap: () => onPartTap(prov.part, prov),
          ),
        ),
    );
  }
}