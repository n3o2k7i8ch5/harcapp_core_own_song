

import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../common.dart';
import '../providers.dart';

class AddButtonsWidget extends StatelessWidget{

  final Function onPressed;
  const AddButtonsWidget({this.onPressed});

  @override
  Widget build(BuildContext context) {

    CurrentItemProvider currItemProv = Provider.of<CurrentItemProvider>(context, listen: false);

    return Row(
      children: [

        Expanded(
          child: SimpleButton(
            padding: EdgeInsets.all(Dimen.MARG_ICON),
            onTap: (){
              currItemProv.addPart(SongPart.empty());
              if(onPressed!=null) onPressed();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.plus, color: accentColor(context)),
                Icon(MdiIcons.musicBox, color: accentColor(context)),
                SizedBox(width: Dimen.MARG_ICON),
                Text('Zwrotka', style: AppTextStyle(fontSize: Dimen.TEXT_SIZE_BIG))
              ],
            ),
          ),
        ),

        Expanded(
          child: SimpleButton(
            padding: EdgeInsets.all(Dimen.MARG_ICON),
            onTap: currItemProv.hasRefren?(){
              RefrenPartProvider refPart = Provider.of<RefrenPartProvider>(context, listen: false);
              currItemProv.addPart(SongPart.from(refPart.part.element));
              if(onPressed!=null) onPressed();
            }:null,
            child: Consumer<CurrentItemProvider>(
              builder: (context, currItemProv, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.plus, color: currItemProv.hasRefren?accentColor(context):iconDisabledColor(context)),
                  Icon(MdiIcons.musicBoxOutline, color: currItemProv.hasRefren?accentColor(context):iconDisabledColor(context)),
                  SizedBox(width: Dimen.MARG_ICON),
                  Text(
                    'Refren',
                    style: AppTextStyle(
                      fontSize: Dimen.TEXT_SIZE_BIG,
                      color: currItemProv.hasRefren?textEnabled(context):iconDisabledColor(context)
                    )
                  )
                ],
              ),
            )
          ),
        )

      ],
    );
  }

}