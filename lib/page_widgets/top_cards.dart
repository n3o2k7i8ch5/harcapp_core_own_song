import 'package:flutter/material.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_classes/common.dart';
import 'package:harcapp_core/comm_widgets/animated_child_slider.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/app_scaffold.dart';
import 'package:harcapp_core/comm_widgets/app_text_field_hint.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../providers.dart';



class TopCards extends StatelessWidget{

  final Function(String) onChangedTitle;
  final Function(String) onChangedAuthor;
  final Function(String) onChangedComposer;
  final Function(String) onChangedPerformer;
  final Function(String) onChangedYT;
  final Function(String) onChangedAddPers;
  final Function(DateTime) onChangedReleaseDate;

  const TopCards({
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
      children: [

        Padding(
          padding: EdgeInsets.only(left: Dimen.DEF_MARG, right: Dimen.DEF_MARG),
          child: Column(
            children: <Widget>[

              Row(
                children: [
                  Expanded(
                    child: Consumer<TitleCtrlProvider>(
                        builder: (context, prov, child) => AppTextFieldHint(
                          controller: prov.controller,
                          hint: 'Tytuł:',
                          style: AppTextStyle(
                            fontSize: Dimen.TEXT_SIZE_BIG,
                            fontWeight: weight.halfBold,
                            color: textEnab_(context),
                          ),
                          hintStyle: AppTextStyle(
                            fontSize: Dimen.TEXT_SIZE_NORMAL,
                            color: hintEnabled(context),
                          ),
                          onChanged: onChangedTitle,
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
                          child: AddTextWidget(item),
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

              Consumer<AuthorCtrlProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  controller: prov.controller,
                  hint: 'Autor słów:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_NORMAL,
                    color: hintEnabled(context),
                  ),
                  onChanged: onChangedAuthor,
                ),
              ),

              Consumer<ComposerCtrlProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  controller: prov.controller,
                  hint: 'Kompozytor muzyki:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_NORMAL,
                    color: hintEnabled(context),
                  ),
                  onChanged: onChangedComposer,
                ),
              ),

              Consumer<PerformerCtrlProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                    controller: prov.controller,
                    hint: 'Wykonawca:',
                    style: AppTextStyle(
                      fontSize: Dimen.TEXT_SIZE_BIG,
                      fontWeight: weight.halfBold,
                      color: textEnab_(context),
                    ),
                    hintStyle: AppTextStyle(
                      fontSize: Dimen.TEXT_SIZE_NORMAL,
                      color: hintEnabled(context),
                    ),
                    onChanged: onChangedPerformer
                ),
              ),

              Consumer<YTCtrlProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  controller: prov.controller,
                  hint: 'Link YouTube:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_NORMAL,
                    color: hintEnabled(context),
                  ),
                  onChanged: onChangedYT,
                ),
              ),

              Consumer<AddPersCtrlProvider>(
                builder: (context, prov, child) => AppTextFieldHint(
                  controller: prov.controller,
                  hint: 'Os. dodająca:',
                  style: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_BIG,
                    fontWeight: weight.halfBold,
                    color: textEnab_(context),
                  ),
                  hintStyle: AppTextStyle(
                    fontSize: Dimen.TEXT_SIZE_NORMAL,
                    color: hintEnabled(context),
                  ),
                  onChanged: onChangedAddPers,
                ),
              ),

            ],
          ),
        ),

        Consumer<ReleaseDateProvider>(
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
                              controller: TextEditingController(
                                  text:
                                  prov.releaseDate==null ?
                                  '':
                                  dateToString(prov.releaseDate, showMonth: prov.showMonth, showDay: prov.showMonth&&prov.showDay)),
                              hint: 'Pierwsze wykonanie:',
                              style: AppTextStyle(
                                fontSize: Dimen.TEXT_SIZE_BIG,
                                fontWeight: weight.halfBold,
                                color: textEnab_(context),
                              ),
                              hintStyle: AppTextStyle(
                                fontSize: Dimen.TEXT_SIZE_NORMAL,
                                color: hintEnabled(context),
                              ),
                              onChanged: (text){
                                if(onChangedReleaseDate != null)
                                  onChangedReleaseDate(prov.releaseDate);
                              },
                              key: ValueKey(prov.releaseDate),
                            ),
                          ),

                          Positioned.fill(
                            child: GestureDetector(
                                child: Container(color: Colors.transparent),
                                onTap: () async {
                                  prov.releaseDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
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
                          textColor: prov.showDay && prov.showMonth?iconEnab_(context):iconDisab_(context),
                          dense: true,
                          margin: EdgeInsets.zero,
                          icon: MdiIcons.calendarOutline,
                          text: 'Pok. dzień',
                          onTap: prov.showMonth?() => prov.showDay = !prov.showDay : null
                      ),

                      SimpleButton.from(
                          textColor: prov.showMonth?iconEnab_(context):iconDisab_(context),
                          dense: true,
                          margin: EdgeInsets.zero,
                          icon: MdiIcons.calendarMonthOutline,
                          text: 'Pok. miesiąc',
                          onTap: () => prov.showMonth = !prov.showMonth
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
  const AddTextWidget(this.controller);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        IconButton(
          icon: Icon(MdiIcons.trashCanOutline),
          onPressed: (){
            HidTitlesProvider prov = Provider.of<HidTitlesProvider>(context, listen: false);
            prov.remove(controller);
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
            color: hintEnabled(context),
          ),
        )),

      ],
    );
  }

}