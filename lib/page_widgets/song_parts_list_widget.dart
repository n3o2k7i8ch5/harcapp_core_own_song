import 'dart:ui' as ui;

import 'package:flutter/material.dart';
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

  static const double ITEM_TOP_MARG = Dimen.DEF_MARG;
  static const double ITEM_BOTTOM_MARG = 12.0;

  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Widget? header;
  final Widget? footer;
  final bool refrenTapable;
  final Function(SongPart, SongPartProvider)? onPartTap;
  final bool shrinkWrap;
  final Function()? onDelete;
  final Function()? onDuplicate;
  final Function()? onReorderFinished;

  const SongPartsListWidget({
    this.controller,
    this.physics,
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
        physics: physics??BouncingScrollPhysics(),
        controller: controller,
        items: prov.song!.songParts!,
        insertDuration: Duration(milliseconds: prov.song!.songParts!.length<=1?0:200),
        removeDuration: Duration(milliseconds: prov.song!.songParts!.length==0?0:500),
        areItemsTheSame: (oldItem, newItem) => oldItem.hashCode == newItem.hashCode,
        onReorderFinished: (item, from, to, newItems){
          prov.song!.songParts = newItems;
          prov.notifyListeners();
          if(onReorderFinished != null) onReorderFinished!();
        },
        itemBuilder: (context, itemAnimation, item, index) => Reorderable(
          key: ValueKey(item.hashCode),
          builder: (context, dragAnimation, inDrag) {
            final t = dragAnimation.value;
            final elevation = ui.lerpDouble(0, AppCard.bigElevation, t)!;
            final color = Color.lerp(background_(context), cardEnab_(context), t);

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
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.only(
                        top: ITEM_TOP_MARG,
                        right: Dimen.DEF_MARG,
                        left: Dimen.DEF_MARG,
                        bottom: ITEM_BOTTOM_MARG
                    ),
                    radius: AppCard.BIG_RADIUS,
                    elevation: elevation,
                    color: color,
                    child: child
                ),
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
              prov.song!.songParts!.isEmpty?
              SongPartCard.EMPTY_HEIGHT + Dimen.ICON_FOOTPRINT + ITEM_TOP_MARG + ITEM_BOTTOM_MARG
                  :0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(MdiIcons.musicNoteOffOutline, color: hintEnab_(context)),

                    SizedBox(height: Dimen.ICON_MARG),

                    Text(
                      'Pusto!\nUżyj poniższych przycisków.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle(
                        color: hintEnab_(context),
                        fontSize: Dimen.TEXT_SIZE_BIG,
                      ),
                    ),
                  ]
              ),
            ),

            if(footer!=null) footer!,

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
            if(onDelete!=null) onDelete!();
          },
        );
      else
        return TopZwrotkaButtons(
          part,
          onDuplicate: (SongPart part){
            scrollToBottom(controller!);
            if(onDuplicate!=null) onDuplicate!();
          },
          onDelete: (SongPart part){
            if(onDelete!=null) onDelete!();
          },
        );
    },
    onTap: !refrenTapable && isRefren?null:() => onPartTap!(part, prov),
  );

}