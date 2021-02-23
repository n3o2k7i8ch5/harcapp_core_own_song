
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/title_show_row_widget.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../common.dart';
import '../providers.dart';
import '../song_part_card.dart';


class RefrenTemplate extends StatelessWidget{

  final Function(SongPart, RefrenPartProvider) onPartTap;
  final Function(bool value) onRefrenEnabledChaned;

  const RefrenTemplate({this.onPartTap, this.onRefrenEnabledChaned});

  @override
  Widget build(BuildContext context) {

    return Consumer<RefrenPartProvider>(
        builder: (context, prov, child) => AppCard(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.only(bottom: 12),
          color: background(context),
          elevation: 0,
          child: Column(
            children: <Widget>[
              SongPartCard.from(
                songPart: prov.part,
                type: SongPartType.REFREN_TEMPLATE,
                topBuilder: (context, part) => Consumer<CurrentItemProvider>(
                  builder: (context, currItemProv, child) => TitleShortcutRowWidget(title: 'Szablon refrenu',
                    icon: prov.isError?MdiIcons.alertOutline:MdiIcons.musicBoxOutline,
                    iconColor: prov.isError?Colors.red:null,
                    titleColor: currItemProv.hasRefren?textEnabled(context):hintEnabled(context),
                    trailing: Switch(
                        value: currItemProv.hasRefren,
                        onChanged: (bool value){
                          currItemProv.hasRefren = !currItemProv.hasRefren;
                          if(onRefrenEnabledChaned != null) onRefrenEnabledChaned(value);
                        }),
                  ),
                ),
                onTap: () => onPartTap(prov.part, prov),
              ),
            ],
          ),
        )
    );
  }
}