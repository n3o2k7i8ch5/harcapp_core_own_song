
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_widgets/title_show_row_widget.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_tags/tag_layout.dart';
import 'package:provider/provider.dart';

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
          if(checked) prov.remove(tag);
          else prov.add(tag);

          if(onChanged!=null) onChanged(prov.checkedTags);
        };

        return Column(
          children: [

            Padding(
              padding: EdgeInsets.only(left: Dimen.ICON_MARG),
              child: TitleShortcutRowWidget(
                title: 'Tagi${prov.count==0?'':' (${prov.count})'}',
                textAlign: TextAlign.start,
                //icon: MdiIcons.tagOutline,
              ),
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