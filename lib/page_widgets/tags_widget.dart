
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_widgets/title_show_row_widget.dart';
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

        Function onTagTap = (String tag, bool checked){
          if(checked) prov.checkedTags.remove(tag);
          else prov.checkedTags.add(tag);

          if(onChanged!=null) onChanged(prov.checkedTags);
        };

        return Column(
          children: [

            TitleShortcutRowWidget(
              title: 'Tagi${prov.count==0?'':' (${prov.count})'}',
              icon: MdiIcons.tagOutline,
            ),

            if(linear)
              TagLayout.linear(
                onTagTap: onTagTap,
                allTags: Tag.ALL_TAG_NAMES,
                checkedTags: prov.checkedTags,
                fontSize: Dimen.TEXT_SIZE_NORMAL,
              )
            else
              TagLayout.wrap(
                onTagTap: onTagTap,
                allTags: Tag.ALL_TAG_NAMES,
                checkedTags: prov.checkedTags,
                fontSize: Dimen.TEXT_SIZE_NORMAL,
              )

          ],
        );
      },
    );
  }

}