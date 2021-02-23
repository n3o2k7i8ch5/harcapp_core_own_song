import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_own_song/page_widgets/scroll_to_bottom.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../common.dart';
import '../providers.dart';
import '../song_part_card.dart';

class SongPartsListWidget extends StatelessWidget{

  final ScrollController controller;
  final Widget header;
  final Widget footer;
  final bool refrenTapable;
  final Function(SongPart, SongPartProvider) onPartTap;
  final bool shrinkWrap;
  final Function() onDelete;
  final Function() onDuplicate;
  final Function() onReorderFinished;

  const SongPartsListWidget({
    this.controller,
    this.header,
    this.footer,
    this.refrenTapable: false,
    this.onPartTap,
    this.shrinkWrap: false,
    this.onDelete,
    this.onDuplicate,
    this.onReorderFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentItemProvider>(
      builder: (context, prov, _) => ImplicitlyAnimatedReorderableList<SongPart>(
        physics: BouncingScrollPhysics(),
        controller: controller,
        items: prov.song.songParts,
        insertDuration: Duration(milliseconds: prov.song.songParts.length<=1?0:200),
        removeDuration: Duration(milliseconds: prov.song.songParts.length==0?0:500),
        areItemsTheSame: (oldItem, newItem) => oldItem.hashCode == newItem.hashCode,
        onReorderFinished: (item, from, to, newItems){
          prov.song.songParts = newItems;
          prov.notifyListeners();
          if(onReorderFinished != null) onReorderFinished();
        },
        itemBuilder: (context, itemAnimation, item, index) => Reorderable(
          key: ValueKey(item.hashCode),
          builder: (context, dragAnimation, inDrag) {
            final t = dragAnimation.value;
            final elevation = ui.lerpDouble(0, AppCard.bigElevation, t);
            final color = Color.lerp(background(context), defCardEnabled(context), t);

            bool isRefren = item.isRefren(context);

            Widget child;

            if(isRefren)
              child = Consumer<RefrenPartProvider>(
                  builder: (context, prov, child) => getSongPartCard<RefrenPartProvider>(item, item.isRefren(context), prov)
              );

            else
              child = ChangeNotifierProvider<SongPartProvider>(
                create: (context) => SongPartProvider(item),
                builder: (context, child) => Consumer<SongPartProvider>(
                    builder: (context, prov, child) => getSongPartCard<SongPartProvider>(item, item.isRefren(context), prov)
                ),
              );


            return SizeFadeTransition(
                sizeFraction: 0.7,
                curve: Curves.easeInOut,
                animation: itemAnimation,
                child: AppCard(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.all(Dimen.DEF_MARG),
                    radius: AppCard.BIG_RADIUS,
                    elevation: elevation,
                    color: color,
                    child: child
                )
            );
          },
        ),
        padding: EdgeInsets.only(bottom: Dimen.DEF_MARG/2),
        shrinkWrap: shrinkWrap,
        header: header,
        footer: Column(
          children: [

            AnimatedContainer(
              duration: Duration(milliseconds: 1),
              height:
              prov.song.songParts.isEmpty?
              SongPartCard.EMPTY_HEIGHT + Dimen.ICON_FOOTPRINT + 4*Dimen.DEF_MARG
                  :0,
              child: AnimatedOpacity(
                opacity: prov.song.songParts.length==0?1:0,
                duration: Duration(milliseconds: 300),
                child: Column(
                  children: [

                    Icon(MdiIcons.musicNoteOffOutline, color: hintEnabled(context)),

                    SizedBox(height: Dimen.ICON_MARG),

                    Text(
                      'Pusto!\nDodaj coś poniższymi przyciskami.',
                      style: AppTextStyle(
                          color: hintEnabled(context),
                          fontSize: Dimen.TEXT_SIZE_BIG
                      ),
                    ),
                  ]
                ),
              ),
            ),

            if(footer!=null) footer,

          ],
        ),
      ),
    );
  }

  getSongPartCard<T extends SongPartProvider>(SongPart part, bool isRefren, T prov) => SongPartCard.from(
    type: isRefren?SongPartType.REFREN:SongPartType.ZWROTKA,
    songPart: part,
    topBuilder: (context, part){
      if(part.isRefren(context))
        return TopRefrenButtons(
          part,
          onDelete: (songPart){
            if(onDelete!=null) onDelete();
          },
        );
      else
        return TopZwrotkaButtons(
          part,
          onDuplicate: (SongPart part){
            scrollToBottom(controller);
            if(onDuplicate!=null) onDuplicate();
          },
          onDelete: (SongPart part){
            if(onDelete!=null) onDelete();
          },
        );
    },
    onTap: !refrenTapable && isRefren?null:() => onPartTap(part, prov),
  );

}