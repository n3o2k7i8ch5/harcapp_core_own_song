
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_tags/tag_layout.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../common.dart';
import '../providers.dart';

class TagsWidget extends StatelessWidget{

  final bool linear;
  final void Function(List<String> tags) onChanged;

  const TagsWidget({this.linear: true, this.onChanged});

  @override
  Widget build(BuildContext context) {

    return Consumer<TagsProvider>(
      builder: (context, prov, child){

        Function onTagClick = (String tag, int i, bool checked){
          prov.neg(i);
          if(onChanged!=null) onChanged(prov.toList());
        };

        return Column(
          children: [

            HeaderWidget('Tagi${prov.count==0?'':' (${prov.count})'}', MdiIcons.tagOutline),

            if(linear)
              TagLayout.linear(
                onTagClick: onTagClick,
                checked: prov.tagsChecked,
                fontSize: Dimen.TEXT_SIZE_NORMAL,
              ),

            if(!linear)
              TagLayout.wrap(
                onTagClick: onTagClick,
                checked: prov.tagsChecked,
                fontSize: Dimen.TEXT_SIZE_NORMAL,
              )
          ],
        );
      },
    );
  }

}