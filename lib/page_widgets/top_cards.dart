import 'package:flutter/material.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_classes/common.dart';
import 'package:harcapp_core/comm_widgets/animated_child_slider.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/app_scaffold.dart';
import 'package:harcapp_core/comm_widgets/app_text_field_hint.dart';
import 'package:harcapp_core/comm_widgets/multi_text_field.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../providers.dart';



class TopCards extends StatelessWidget{

  final Color accentColor;
  final Function(String) onChangedTitle;
  final Function(List<String>) onChangedAuthor;
  final Function(List<String>) onChangedComposer;
  final Function(List<String>) onChangedPerformer;
  final Function(String) onChangedYT;
  final Function(List<String>) onChangedAddPers;
  final Function(DateTime) onChangedReleaseDate;

  const TopCards({
    this.accentColor,
    this.onChangedTitle,
    this.onChangedAuthor,
    this.onChangedComposer,
    this.onChangedPerformer,
    this.onChangedYT,
    this.onChangedAddPers,
    this.onChangedReleaseDate,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Padding(
          padding: EdgeInsets.only(left: Dimen.DEF_MARG, right: Dimen.DEF_MARG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              Row(
                children: [
                  Expanded(
                    child: Consumer<TitleCtrlProvider>(
                        builder: (context, prov, child) => AppTextFieldHint(
                          accentColor: accentColor,
                          controller: prov.controller,
                          hint: 'Tytuł:',
                          style: AppTextStyle(
                            fontSize: Dimen.TEXT_SIZE_BIG,
                            fontWeight: weight.halfBold,
                            color: textEnab_(context),
                          ),
                          hintStyle: AppTextStyle(
                            fontSize: Dimen.TEXT_SIZE_BIG,
                            color: hintEnab_(context),
                          ),
                          onAnyChanged: (values) => onChangedTitle?.call(values[0]),
                        )
                    ),
                  ),

                  Consumer<HidTitlesProvider>(
                      builder: (context, provider, child) =>
                          AnimatedChildSlider(
                            index: provider.hasAny?1:0,
                            children: [
                              IconButton(
                                icon: Icon(MdiIcons.plus),
                                onPressed: (){
                                  HidTitlesProvider prov = Provider.of<HidTitlesProvider>(context, listen: false);
                                  prov.add();
                                },
                              ),

                              IconButton(
                                icon: Icon(MdiIcons.informationOutline),
                                onPressed: (){
                                  AppScaffold.showMessage(context, 'Tytuły ukryte są dodatkowymi kluczami wyszukwiania piosneki.');
                                },
                              )
                            ],
                          )
                  )
                ],
              ),

              Consumer<HidTitlesProvider>(
                builder: (context, provider, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    ImplicitlyAnimatedList<TextEditingController>(
                      physics: BouncingScrollPhysics(),
                      items: provider.controllers,
                      areItemsTheSame: (a, b) => a.hashCode == b.hashCode,
                      itemBuilder: (context, animation, item, index) {
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: AddTextWidget(
                            item,
                            onRemoved: (){

                            },
                          ),
                        );
                      },
                      removeItemBuilder: (context, animation, oldItem) {
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: AddTextWidget(oldItem),
                        );
                      },
                      shrinkWrap: true,
                    ),

                    AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: provider.hasAny?2*Dimen.ICON_MARG+Dimen.ICON_FOOTPRINT:0,
                        child: AnimatedOpacity(
                          opacity: provider.hasAny?1:0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: SimpleButton(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.all(Dimen.ICON_MARG),
                            onTap: provider.isLastEmpty?null:() => provider.add(),
                            child: Row(
                              children: [
                                Icon(MdiIcons.plus, color: provider.isLastEmpty?iconDisab_(context):iconEnab_(context)),
                                SizedBox(width: Dimen.ICON_MARG),
                                Text(
                                  'Dodaj tytuł ukryty',
                                  style: AppTextStyle(color: provider.isLastEmpty?iconDisab_(context):iconEnab_(context)),
                                )
                              ],
                            ),
                          ),
                        )
                    ),

                  ],
                ),
              ),

              Consumer<CurrentItemProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  accentColor: accentColor,
                  hint: 'Autor słów:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    color: hintEnab_(context),
                  ),
                  multi: true,
                  multiHintTop: 'Autorzy słów:',
                  multiExpanded: true,
                  multiController: MultiTextFieldController(texts: prov.song.authors),
                  onAnyChanged: onChangedAuthor,
                  key: ValueKey(prov.song),
                ),
              ),

              Consumer<CurrentItemProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  accentColor: accentColor,
                  hint: 'Kompozytor muzyki:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    color: hintEnab_(context),
                  ),
                  multi: true,
                  multiHintTop: 'Kompozytorzy muzyki:',
                  multiExpanded: true,
                  multiController: MultiTextFieldController(texts: prov.song.composers),
                  onAnyChanged: onChangedComposer,
                  key: ValueKey(prov.song),
                ),
              ),

              Consumer<CurrentItemProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  accentColor: accentColor,
                  hint: 'Wykonawca:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    color: hintEnab_(context),
                  ),
                  multi: true,
                  multiHintTop: 'Wykonawcy:',
                  multiExpanded: true,
                  multiController: MultiTextFieldController(texts: prov.song.performers),
                  onAnyChanged: onChangedPerformer,
                  key: ValueKey(prov.song),
                ),
              ),

              Consumer<CurrentItemProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  accentColor: accentColor,
                  controller: TextEditingController(text: prov.youtubeLink),
                  hint: 'Link YouTube:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    color: hintEnab_(context),
                  ),
                  onAnyChanged: (values) => onChangedYT?.call(values[0]),
                  key: ValueKey(prov.song),
                ),
              ),

              Consumer<CurrentItemProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  accentColor: accentColor,
                  hint: 'Os. dodająca:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    color: hintEnab_(context),
                  ),
                  multi: true,
                  multiHintTop: 'Os. dodające:',
                  multiExpanded: true,
                  multiController: MultiTextFieldController(texts: prov.song.addPers),
                  onAnyChanged: onChangedAddPers,
                  key: ValueKey(prov.song),
                ),
              ),

            ],
          ),
        ),

        Consumer<CurrentItemProvider>(
            builder: (context, prov, child) => Column(
              children: [
                Row(
                  children: [

                    SizedBox(width: Dimen.DEF_MARG),

                    Expanded(
                      child: Stack(
                        children: [

                          IgnorePointer(
                            ignoring: true,
                            child: AppTextFieldHint(
                              accentColor: accentColor,
                              controller: TextEditingController(
                                  text:
                                  prov.releaseDate==null ?
                                  '':
                                  dateToString(prov.releaseDate, showMonth: prov.showRelDateMonth, showDay: prov.showRelDateMonth&&prov.showRelDateDay)),
                              hint: 'Data pierwszego wykonania:',
                              style: AppTextStyle(
                                fontSize: Dimen.TEXT_SIZE_BIG,
                                fontWeight: weight.halfBold,
                                color: textEnab_(context),
                              ),
                              hintStyle: AppTextStyle(
                                fontSize: Dimen.TEXT_SIZE_BIG,
                                color: hintEnab_(context),
                              ),
                              onAnyChanged: (text){
                                if(onChangedReleaseDate != null)
                                  onChangedReleaseDate(prov.releaseDate);
                              },
                              key: ValueKey(Tuple3(prov.releaseDate, prov.showRelDateMonth, prov.showRelDateDay)),
                            ),
                          ),

                          Positioned.fill(
                            child: GestureDetector(
                                child: Container(color: Colors.transparent),
                                onTap: () async {
                                  prov.releaseDate = await showDatePicker(
                                    context: context,
                                    initialDate: prov.releaseDate??DateTime.now(),
                                    firstDate: DateTime(966),
                                    lastDate: DateTime.now(),
                                  );
                                }
                            ),
                          )

                        ],
                      ),
                    ),

                    IconButton(
                        icon: Icon(MdiIcons.close),
                        onPressed: prov.releaseDate==null?null:(){
                          prov.releaseDate = null;
                        }
                    ),

                    SizedBox(width: Dimen.DEF_MARG),

                  ],
                ),

                if(prov.releaseDate != null)
                  Row(
                    children: [

                      SimpleButton.from(
                          textColor: prov.showRelDateDay && prov.showRelDateMonth?iconEnab_(context):iconDisab_(context),
                          dense: true,
                          margin: EdgeInsets.zero,
                          icon: MdiIcons.calendarOutline,
                          text: 'Pok. dzień',
                          onTap: prov.showRelDateMonth?() => prov.showRelDateDay = !prov.showRelDateDay : null
                      ),

                      SimpleButton.from(
                          textColor: prov.showRelDateMonth?iconEnab_(context):iconDisab_(context),
                          dense: true,
                          margin: EdgeInsets.zero,
                          icon: MdiIcons.calendarMonthOutline,
                          text: 'Pok. miesiąc',
                          onTap: () => prov.showRelDateMonth = !prov.showRelDateMonth
                      )

                    ],
                  )
              ],
            )
        )

      ],
    );
  }

}

class AddTextWidget extends StatelessWidget{

  final TextEditingController controller;
  final void Function() onRemoved;
  const AddTextWidget(this.controller, {this.onRemoved});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        IconButton(
          icon: Icon(MdiIcons.trashCanOutline),
          onPressed: (){
            HidTitlesProvider prov = Provider.of<HidTitlesProvider>(context, listen: false);
            prov.remove(controller);
            if(onRemoved != null) onRemoved();
          },
        ),

        Expanded(child: AppTextFieldHint(
          hint: 'Tytuł ukryty:',
          hintTop: '',
          controller: controller,
          style: AppTextStyle(
            fontSize: Dimen.TEXT_SIZE_BIG,
            //fontWeight: weight.halfBold,
            color: textEnab_(context),
          ),
          hintStyle: AppTextStyle(
            fontSize: Dimen.TEXT_SIZE_NORMAL,
            color: hintEnab_(context),
          ),
        )),

      ],
    );
  }

}