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
  
  @override
  void initState() {
    texts = [];
    if(initVals != null)
      texts.addAll(initVals);

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
        onRemoveTap: () => setState(() => texts.removeAt(i)),
      ));
    }

    children.add(
      SimpleButton.from(
        context: context,
        text: 'Dodaj',
        icon: MdiIcons.plus,
        onTap: () => setState(() => texts.add('')), 
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

  const Item({@required this.initText, @required this.hint, this.onRemoveTap});

  @override
  State<StatefulWidget> createState() => ItemState();

}

class ItemState extends State<Item>{
  
  String get initText => widget.initText;
  String get hint => widget.hint;
  void Function() get onRemoveTap => widget.onRemoveTap;

  TextEditingController controller;
  bool editing;

  @override
  void initState() {
    controller = TextEditingController(text: initText);
    editing = false;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => setState(() => editing = true),
      radius: AppCard.BIG_RADIUS,
      padding: EdgeInsets.only(left: Dimen.ICON_MARG),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          ConstrainedBox(
              constraints: BoxConstraints(minWidth: 40.0),
              child:
              editing?

              IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    style: AppTextStyle(fontSize: Dimen.TEXT_SIZE_BIG),
                    decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTextStyle(
                          color: hintEnab_(context),
                          fontSize: Dimen.TEXT_SIZE_BIG,
                        ),
                        border: InputBorder.none
                    ),
                  )
              ):

              Text(
                controller.text,
                style: AppTextStyle(
                  fontSize: Dimen.TEXT_SIZE_BIG,
                ),
              ),
          ),

          if(editing)
            SimpleButton.from(
              context: context,
              icon: MdiIcons.check,
              iconSize: 20,
              onTap: () => setState(() => editing = false),
            )
          else
            SimpleButton.from(
              context: context,
              icon: MdiIcons.close,
              iconSize: 20,
              onTap: onRemoveTap,
            )

        ],
      )
    );
  }

}