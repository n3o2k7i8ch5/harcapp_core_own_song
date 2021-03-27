
import 'package:flutter/material.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_own_song/providers.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'common.dart';

enum SongPartType{
  ZWROTKA,
  REFREN,
  REFREN_TEMPLATE
}

class SongPartCard extends StatelessWidget{

  static const int MIN_LINE_CNT = 4;

  static const double EMPTY_HEIGHT = MIN_LINE_CNT*Dimen.TEXT_SIZE_NORMAL+4*Dimen.DEF_MARG;

  final SongPart songPart;
  final SongPartType type;
  final Widget Function(BuildContext, SongPart) topBuilder;
  final Function onTap;

  final FocusNode focusNode = FocusNode();

  SongPartCard(
      this.songPart,
      this.type,
      {
        this.topBuilder,
        this.onTap
      });

  static SongPartCard from(
      {@required SongPart songPart,
        @required SongPartType type,
        Widget Function(BuildContext, SongPart) topBuilder,
        Function onTap
      }) =>
      SongPartCard(
          songPart,
          type,
          topBuilder: topBuilder,
          onTap: onTap
      );

  @override
  Widget build(BuildContext context) {

    RefrenEnabProvider isRefProv = Provider.of<RefrenEnabProvider>(context);

    return Consumer<RefrenEnabProvider>(
      builder: (context, prov, _){

        Widget songTextCard = Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: SongTextWidget(this, isRefProv),
            )
        );

        Widget songChordsCard = Container(
            child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: CHORDS_WIDGET_MIN_WIDTH),
                child: SongChordsWidget(this, isRefProv)
            )
        );

        String emptText;
        IconData iconData;
        bool pressable = false;

        if(type == SongPartType.ZWROTKA){
          if(songPart.isEmpty) {
            emptText = 'Edytuj zwrotkę';
            iconData = MdiIcons.pencilOutline;
            pressable = true;
          }
        }else if(type == SongPartType.REFREN){
          if(prov.refEnab) {
            if(songPart.isEmpty)
              emptText = 'Refren pusty. Edytuj szablon powyżej.';
          }else
            emptText = 'Refren ukryty. Nie będzie wyświetlany w piosence.';
        }else if(type == SongPartType.REFREN_TEMPLATE){
          if(songPart.isEmpty) {
            emptText = 'Edytuj szablon';
            iconData = MdiIcons.pencilPlusOutline;
            pressable = true;
          }
        }

        Widget main;

        if(emptText==null)
          main = Row(
            children: <Widget>[
              songTextCard,
              SizedBox(width: Dimen.DEF_MARG),
              songChordsCard
            ],
          );
        else{

          List<Widget> children = [
            Icon(iconData, color: pressable?iconEnab_(context):hintEnab_(context)),
            SizedBox(height: Dimen.ICON_MARG, width: Dimen.ICON_MARG),
            Text(
              emptText,
              style: AppTextStyle(
                  color: pressable?iconEnab_(context):hintEnab_(context),
                  fontSize: Dimen.TEXT_SIZE_BIG,
                  fontWeight: pressable?weight.halfBold:weight.normal
              ),
              textAlign: TextAlign.center,
            ),
          ];

          main = SizedBox(
              height: MIN_LINE_CNT*Dimen.TEXT_SIZE_NORMAL,
              child:
              pressable?
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ):
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              )
          );

        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if(topBuilder!=null) topBuilder(context, songPart),

            SimpleButton(
              radius: AppCard.BIG_RADIUS,
              padding: EdgeInsets.all(Dimen.DEF_MARG),
              margin: EdgeInsets.only(top: Dimen.DEF_MARG, bottom: Dimen.DEF_MARG),
              child: main,
              onTap: onTap
            )
          ],
        );

      },
    );


  }
}

class SongTextWidget extends StatelessWidget{

  final SongPartCard parent;
  final RefrenEnabProvider isRefProv;

  const SongTextWidget(this.parent, this.isRefProv);

  bool isRefren(BuildContext context) => parent.songPart.isRefren(context);
  bool get hasRefren => isRefProv.refEnab;

  FocusNode get focusNode => parent.focusNode;

  @override
  Widget build(BuildContext context) {

    Color textColor;

    if(parent.type == SongPartType.ZWROTKA) textColor = textEnab_(context);
    else if(parent.type == SongPartType.REFREN) textColor = textDisab_(context);
    else if(parent.type == SongPartType.REFREN_TEMPLATE) textColor = textEnab_(context);

    return Padding(
      padding: EdgeInsets.only(left: parent.songPart.shift?Dimen.ICON_SIZE:0),
      child: Text(
        text,
        style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: Dimen.TEXT_SIZE_NORMAL,
            color: textColor
        ),
      ),
    );
  }

  String get text{

    String songText = parent.songPart.getText();
    int textLineCnt = songText.split('\n').length;
    int chrdLineCnt = parent.songPart.chords.split('\n').length;

    int newLinesCnt = 0;
    if(textLineCnt<chrdLineCnt) {
      if(chrdLineCnt>SongPartCard.MIN_LINE_CNT) newLinesCnt = chrdLineCnt - textLineCnt;
      else newLinesCnt = SongPartCard.MIN_LINE_CNT - textLineCnt;
    }else{
      if(textLineCnt<SongPartCard.MIN_LINE_CNT) newLinesCnt = SongPartCard.MIN_LINE_CNT - textLineCnt;
    }

    return songText + '\n'*newLinesCnt;
  }
}

class SongChordsWidget extends StatelessWidget{

  final SongPartCard parent;
  final RefrenEnabProvider isRefProv;

  const SongChordsWidget(this.parent, this.isRefProv);

  bool isRefren(BuildContext context) => parent.songPart.isRefren(context);
  bool get hasRefren => isRefProv.refEnab;

  @override
  Widget build(BuildContext context) {

    Color textColor;

    if(parent.type == SongPartType.ZWROTKA) textColor = textEnab_(context);
    else if(parent.type == SongPartType.REFREN) textColor = textDisab_(context);
    else if(parent.type == SongPartType.REFREN_TEMPLATE) textColor = textEnab_(context);

    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: Dimen.TEXT_SIZE_NORMAL,
          color: textColor
      ),
    );
  }

  String get text{

    String songChords = parent.songPart.chords;
    int chrdLineCnt = songChords.split('\n').length;
    int textLineCnt = parent.songPart.getText().split('\n').length;

    int newLinesCnt = 0;
    if(chrdLineCnt<textLineCnt) {
      if(textLineCnt>SongPartCard.MIN_LINE_CNT) newLinesCnt = textLineCnt - chrdLineCnt;
      else newLinesCnt = SongPartCard.MIN_LINE_CNT - chrdLineCnt;
    }else{
      if(chrdLineCnt<SongPartCard.MIN_LINE_CNT) newLinesCnt = SongPartCard.MIN_LINE_CNT - chrdLineCnt;
    }

    return songChords + '\n'*newLinesCnt;
  }

}

class TopZwrotkaButtons extends StatelessWidget{

  final SongPart songPart;
  final Function(SongPart) onDuplicate;
  final Function(SongPart) onDelete;
  final bool showName;

  const TopZwrotkaButtons(
      this.songPart,
      {this.onDuplicate,
        this.onDelete,
        this.showName: true
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[

        Padding(
          padding: EdgeInsets.all(Dimen.ICON_MARG),
          child: Handle(child: Icon(MdiIcons.swapVertical, color: iconEnab_(context))),
        ),

        Expanded(
            child: showName?
            Text('Zwrotka', style: AppTextStyle(fontSize: Dimen.TEXT_SIZE_BIG, fontWeight: weight.halfBold, color: hintEnab_(context))):
            Container()
        ),

        if(songPart.isError)
          Padding(
              padding: EdgeInsets.all(Dimen.ICON_MARG),
              child: Icon(MdiIcons.alertCircleOutline, color: Colors.red)
          ),

        IconButton(
          icon: Icon(MdiIcons.contentDuplicate, color: iconEnab_(context)),
          onPressed: (){
            if(onDuplicate!=null) onDuplicate(songPart);
            Provider.of<CurrentItemProvider>(context, listen: false).addPart(songPart.copy());
          },
        ),


        IconButton(
          icon: Icon(MdiIcons.trashCanOutline, color: iconEnab_(context)),
          onPressed: (){
            if(onDelete!=null) onDelete(songPart);
            Provider.of<CurrentItemProvider>(context, listen: false).removePart(songPart);
          },
        ),

      ],
    );
  }

}

class TopRefrenButtons extends StatelessWidget{

  final SongPart songPart;
  final Function(SongPart) onDelete;
  final bool showName;

  const TopRefrenButtons(
      this.songPart,
      {
      this.onDelete,
      this.showName: true
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[

        Padding(
          padding: EdgeInsets.all(Dimen.ICON_MARG),
          child: Handle(child: Icon(MdiIcons.swapVertical, color: iconEnab_(context))),
        ),

        Expanded(
            child: showName?
            Text('Refren', style: AppTextStyle(fontSize: Dimen.TEXT_SIZE_BIG, fontWeight: weight.halfBold, color: hintEnab_(context))):
            Container()
        ),

        IconButton(
          icon: Icon(MdiIcons.trashCanOutline, color: iconEnab_(context)),
          onPressed: (){
            if(onDelete!=null) onDelete(songPart);
            Provider.of<CurrentItemProvider>(context, listen: false).removePart(songPart);
          },
        ),

      ],
    );
  }

}