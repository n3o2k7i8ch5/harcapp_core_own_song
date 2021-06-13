import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/comm_widgets/text_field_fit.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MultiTextField extends StatefulWidget{

  final List<String> initVals;
  final String hint;

  const MultiTextField({this.initVals, this.hint});

  @override
  State<StatefulWidget> createState() => MultiTextFieldState();


}

class MultiTextFieldState extends State<MultiTextField>{

  List<String> get initVals => widget.initVals;
  String get hint => widget.hint;

  List<String> texts;
  List<GlobalKey<ItemState>> keys;
  
  @override
  void initState() {
    texts = [];
    if(initVals != null)
      texts.addAll(initVals);

    keys = [];
    for(int i=0; i<texts.length; i++)
      keys.add(GlobalKey<ItemState>());

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    
    List<Widget> children = [];
    for(int i=0; i<texts.length; i++) {
      String text = texts[i];
      children.add(Item(
        initText: text,
        hint: hint,
        onRemoveTap: () => setState((){
          texts.removeAt(i);
          keys.removeAt(i);
        }),
        key: keys[i],
      ));
    }

    children.add(
      SimpleButton.from(
        textColor: accent_(context),
        text: 'Dodaj',
        icon: MdiIcons.plus,
        iconLeading: false,
        textSize: Dimen.TEXT_SIZE_NORMAL,
        iconSize: 20.0,
        onTap: () => setState((){
          texts.add('');
          keys.add(GlobalKey<ItemState>());
        }),
      )
    );
    
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      children: children,
      runSpacing: Dimen.DEF_MARG,
      spacing: Dimen.DEF_MARG,
    );
  }


}

class Item extends StatefulWidget{
  
  final String initText;
  final String hint;
  final void Function() onRemoveTap;

  const Item({@required this.initText, @required this.hint, this.onRemoveTap, Key key}):super(key: key);

  @override
  State<StatefulWidget> createState() => ItemState();

}

class ItemState extends State<Item>{

  FocusNode focusNode;

  String get initText => widget.initText;
  String get hint => widget.hint;
  void Function() get onRemoveTap => widget.onRemoveTap;

  TextEditingController controller;
  bool editing;

  @override
  void initState() {
    focusNode = FocusNode();
    focusNode.addListener(() {
      if(!focusNode.hasFocus)
        editing = false;

      setState((){});
    });

    controller = TextEditingController(text: initText);
    editing = false;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: editing?AppCard.bigElevation:0,
      color: editing?cardEnab_(context):background_(context),
      onTap: () => setState(() => editing = true),
      radius: AppCard.BIG_RADIUS,
      padding: EdgeInsets.only(left: Dimen.ICON_MARG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          ConstrainedBox(
              constraints: BoxConstraints(minWidth: 40.0, maxHeight: Dimen.TEXT_SIZE_NORMAL),
              child:
              editing?

              IntrinsicWidth(
                  child: TextField(
                    focusNode: focusNode,
                    controller: controller,
                    style: AppTextStyle(fontSize: Dimen.TEXT_SIZE_NORMAL),
                    textAlignVertical: TextAlignVertical.center,
                    scrollPadding: EdgeInsets.zero,
                    decoration: InputDecoration(
                        isCollapsed: true,
                        //contentPadding: EdgeInsets.zero,
                        hintText: hint,
                        hintStyle: AppTextStyle(
                          color: hintEnab_(context),
                          fontSize: Dimen.TEXT_SIZE_NORMAL,
                        ),
                        border: InputBorder.none
                    ),
                  ),
              ):

              Text(
                controller.text.length==0?hint:controller.text,
                style: AppTextStyle(
                  fontSize: Dimen.TEXT_SIZE_NORMAL,
                  color: controller.text.length==0?hintEnab_(context):textEnab_(context)
                ),
              ),
          ),

          if(focusNode.hasFocus && editing)
            SimpleButton.from(
              context: context,
              icon: MdiIcons.check,
              iconSize: 20,
              margin: EdgeInsets.zero,
              onTap: () => setState(() => editing = false),
            )
          else if(focusNode.hasFocus && !editing)
            SimpleButton.from(
              context: context,
              icon: MdiIcons.close,
              iconSize: 20,
              margin: EdgeInsets.zero,
              onTap: onRemoveTap,
            )
          else
            SizedBox(
              height: 20 + 2*Dimen.ICON_MARG,
              width: Dimen.ICON_MARG,
            )

        ],
      )
    );
  }

  void setEditing(editing) => setState(() => this.editing = editing);

}