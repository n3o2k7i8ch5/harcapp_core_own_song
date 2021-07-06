
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:harcapp_core/comm_classes/app_text_style.dart';
import 'package:harcapp_core/comm_classes/color_pack.dart';
import 'package:harcapp_core/comm_widgets/animated_child_slider.dart';
import 'package:harcapp_core/comm_widgets/app_card.dart';
import 'package:harcapp_core/comm_widgets/app_scaffold.dart';
import 'package:harcapp_core/comm_widgets/chord_shifter.dart';
import 'package:harcapp_core/comm_widgets/simple_button.dart';
import 'package:harcapp_core/comm_widgets/text_field_fit.dart';
import 'package:harcapp_core/comm_widgets/text_field_fit_chords.dart';
import 'package:harcapp_core/dimen.dart';
import 'package:harcapp_core_own_song/page_widgets/song_part_editor_template/providers.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import 'errors.dart';
import '../../providers.dart';

const double TEXT_FIELD_TOP_PADD = Dimen.TEXT_FIELD_PADD - 7;

class SongPartEditorTemplate extends StatefulWidget{

  //final SongPart songPart;
  final String? initText;
  final String? initChord;
  final bool? initShifted;
  final bool isRefren;

  final void Function(String, int)? onTextChanged;
  final void Function(String, int)? onChordsChanged;
  final void Function(bool)? onShiftedChanged;

  final Widget Function(BuildContext, SongPartEditorTemplateState)? topBuilder;
  final Widget Function(BuildContext, SongPartEditorTemplateState)? bottomBuilder;

  final double elevation;

  const SongPartEditorTemplate(
      {this.initText,
        this.initChord,
        this.initShifted,

        required this.isRefren,

        this.onTextChanged,
        this.onChordsChanged,
        this.onShiftedChanged,

        this.topBuilder,
        this.bottomBuilder,

        this.elevation: AppCard.bigElevation,

        Key? key
      }):super(key: key);

  @override
  State<StatefulWidget> createState() => SongPartEditorTemplateState();
}


class SongPartEditorTemplateState extends State<SongPartEditorTemplate>{

  String? get initText => widget.initText;
  String? get initChord => widget.initChord;
  bool? get initShifted => widget.initShifted;

  bool get isRefren => widget.isRefren;

  void Function(String, int)? get onTextChanged => widget.onTextChanged;
  void Function(String, int)? get onChordsChanged => widget.onChordsChanged;
  void Function(bool)? get onShiftedChanged => widget.onShiftedChanged;

  //late bool showErrBar;

  late LinkedScrollControllerGroup _controllers;
  late ScrollController textScrollController;
  late ScrollController chordsScrollController;

  late TextEditingController textController;
  late TextEditingController chordsController;

  @override
  void initState() {

    _controllers = LinkedScrollControllerGroup();
    textScrollController = _controllers.addAndGet();
    chordsScrollController = _controllers.addAndGet();

    textController = TextEditingController(text: initText);
    chordsController = TextEditingController(text: initChord);

    super.initState();
  }

  @override
  void dispose() {
    textScrollController.dispose();
    chordsScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      backgroundColor: Colors.transparent,
      body: AppCard(
          radius: AppCard.BIG_RADIUS,
          elevation: widget.elevation,
          padding: EdgeInsets.zero,
          margin: AppCard.normMargin,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => TextProvider(text: initText??'')),
              ChangeNotifierProvider(create: (context) => ChordsProvider(chords: initChord??'')),
              ChangeNotifierProvider(create: (context) => TextShiftProvider(shifted: initShifted??isRefren, onChanged: onShiftedChanged)),
              ChangeNotifierProvider(create: (context) => ErrorProvider<ChordsMissingError>(init: (errProv) => ChordsMissingError.handleErrors(context, errProv))),
              ChangeNotifierProvider(create: (context) => ErrorProvider<TextTooLongError>(init: (errProv) => TextTooLongError.handleErrors(context, errProv))),
            ],
            builder: (context, _) => Column(
              children: [

                if(widget.topBuilder!=null) widget.topBuilder!(context, this),

                Expanded(
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) => Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[

                          Expanded(
                              child: SongTextWidget(
                                  isRefren: isRefren,
                                  scrollController: textScrollController,
                                  onChanged: (text, errCount) => onTextChanged?.call(text, errCount)
                              )
                          ),

                          SongChordsWidget(
                              isRefren: isRefren,
                              scrollController: chordsScrollController,
                              onChanged: (text, errCount) => onChordsChanged?.call(text, errCount)
                          )

                        ],
                      ),
                    )
                ),

                if(widget.bottomBuilder!=null) widget.bottomBuilder!(context, this),

              ],
            ),
          )
      ),
    );

  }

}

class SongTextWidget extends StatefulWidget{

  final bool isRefren;
  final ScrollController scrollController;
  final void Function(String, int)? onChanged;

  const SongTextWidget({
    required this.isRefren,
    required this.scrollController,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _SongTextWidgetState();

}

class _SongTextWidgetState extends State<SongTextWidget>{

  bool get isRefren => widget.isRefren;
  ScrollController get scrollController => widget.scrollController;
  TextEditingController get textController => Provider.of<TextProvider>(context, listen: false).controller;
  TextEditingController get chordsController => Provider.of<ChordsProvider>(context, listen: false).controller;
  void Function(String, int)? get onChanged => widget.onChanged;

  late FocusNode focusNode;

  String correctText(String text){

    List<String> lines = text.split('\n');
    String result = '';

    for(int i=0; i<lines.length; i++){
      String line = lines[i];

      if(line.length == 0){
        if(i < lines.length-1)
          result += '\n';
        continue;
      }

      int removeFromEnd = 0;
      while(
      line[line.length-1-removeFromEnd] == ' ' ||
          line[line.length-1-removeFromEnd] == '.' ||
          line[line.length-1-removeFromEnd] == ',' ||
          line[line.length-1-removeFromEnd] == ':' ||
          line[line.length-1-removeFromEnd] == ';')
        removeFromEnd++;
      line = line.substring(0, line.length-removeFromEnd);

      int removeFromStart = 0;
      while(line[removeFromStart] == ' ')
        removeFromStart++;
      line = line.substring(removeFromStart);


      if(line[0].toUpperCase() != line[0])
        line = line[0].toUpperCase() + line.substring(1);


      result += line;
      if(i < lines.length-1)
        result += '\n';

    }

    return result;
  }

  _onChanged() => onChanged?.call(textController.text, handleErrors(context, isRefren));

  @override
  void initState() {
    focusNode = FocusNode();
    focusNode.addListener(() {
      if(focusNode.hasFocus)
        return;

      if(!mounted)
        return;

      textController.text = correctText(textController.text);
    });

    textController.addListener(_onChanged);
    super.initState();
  }

  @override
  void dispose() {
    textController.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(focusNode),
      child: AppCard(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppCard.BIG_RADIUS),
          bottomLeft: Radius.circular(AppCard.BIG_RADIUS),
        ),
        padding: EdgeInsets.only(left: Dimen.DEF_MARG/2, right: 1, bottom: Dimen.DEF_MARG/2),
        margin: AppCard.normMargin,
        elevation: 0,
        color: background_(context),
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            controller: scrollController,
            child: Consumer<TextShiftProvider>(
              builder: (context, provider, child) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOutQuad,
                      width: provider.shifted?Dimen.ICON_SIZE + Dimen.ICON_MARG:0
                  ),
                  Expanded(child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: TextFieldFit(
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: Dimen.TEXT_SIZE_NORMAL,
                            color: textEnab_(context),
                          ),
                          decoration: InputDecoration(
                              hintText: 'Słowa ${isRefren?'refrenu':'zwrotki'}',
                              hintStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: Dimen.TEXT_SIZE_NORMAL,
                                  color: hintEnab_(context)
                              ),
                              border: InputBorder.none,
                              isDense: true
                          ),
                          minLines: chordsController.text.split('\n').length,
                          maxLines: null,
                          focusNode: focusNode,
                          autofocus: false,
                          minWidth: Dimen.ICON_FOOTPRINT*2,
                          inputFormatters: [ALLOWED_TEXT_REGEXP],
                          controller: textController
                      )
                  )),
                  Stack(
                    children: [
                      Positioned.fill(child: LineCount()),
                      TextLengthWarning(),
                    ],
                  )

                ],
              ),
            )
        ),
      ),
    );

  }

}

class SongChordsWidget extends StatefulWidget{

  final bool isRefren;
  final ScrollController scrollController;
  final void Function(String, int)? onChanged;

  SongChordsWidget({
    required this.isRefren,
    required this.scrollController,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _SongChordsWidgetState();

}

class _SongChordsWidgetState extends State<SongChordsWidget>{

  bool get isRefren => widget.isRefren;
  ScrollController get scrollController => widget.scrollController;
  TextEditingController get textController => Provider.of<TextProvider>(context, listen: false).controller;
  TextEditingController get chordsController => Provider.of<ChordsProvider>(context, listen: false).controller;
  void Function(String, int)? get onChanged => widget.onChanged;

  void _onChanged() => onChanged?.call(chordsController.text, handleErrors(context, isRefren));

  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    chordsController.addListener(_onChanged);
    super.initState();
  }

  @override
  void dispose() {
    chordsController.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(focusNode),
      child: AppCard(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppCard.BIG_RADIUS),
          bottomRight: Radius.circular(AppCard.BIG_RADIUS),
        ),
        padding: EdgeInsets.only(left: Dimen.DEF_MARG/2, right: Dimen.DEF_MARG/2, bottom: Dimen.DEF_MARG/2),
        margin: AppCard.normMargin,
        elevation: 0,
        color: background_(context),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          controller: scrollController,
          child: Stack(
            children: [

              Positioned(
                  top: TEXT_FIELD_TOP_PADD,
                  right: 0,
                  left: 0,
                  child: ChordPresenceWarning()
              ),

              TextFieldFitChords(
                  focusNode: focusNode,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: Dimen.TEXT_SIZE_NORMAL,
                    color: textEnab_(context),
                  ),
                  decoration: InputDecoration(
                      hintText: 'Chwyty ${isRefren?'ref.':'zwr.'}',
                      hintStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: Dimen.TEXT_SIZE_NORMAL,
                          color: hintEnab_(context)
                      ),
                      border: InputBorder.none,
                      isDense: true
                  ),
                  minLines: textController.text.split('\n').length,
                  maxLines: null,
                  minWidth: CHORDS_WIDGET_MIN_WIDTH,
                  controller: chordsController
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class ButtonsWidget extends StatelessWidget{

  final void Function()? onCheckPressed;
  final void Function(String, int)? onChordsChanged;
  final void Function()? onAlertTap;

  final bool isRefren;

  const ButtonsWidget({required this.isRefren, this.onCheckPressed, this.onChordsChanged, this.onAlertTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        IconButton(
            icon: Icon(MdiIcons.check),
            onPressed: onCheckPressed
        ),

        isRefren?
        Padding(
          padding: EdgeInsets.all(Dimen.ICON_MARG),
          child: Icon(
              MdiIcons.rayStartArrow,
              color: iconDisab_(context)
          ),
        )
            :
        Consumer<TextShiftProvider>(
            builder: (context, provider, child) => IconButton(
              icon: AnimatedChildSlider(
                reverse: provider.shifted,
                direction: Axis.horizontal,
                index: provider.shifted?1:0,
                children: [
                  Icon(
                      MdiIcons.circleMedium,
                      color: iconEnab_(context)
                  ),
                  Icon(
                      MdiIcons.rayStartArrow,
                      color: iconEnab_(context)
                  )
                ],
              ),
              onPressed: isRefren?null:(){
                TextShiftProvider prov = Provider.of<TextShiftProvider>(context, listen: false);
                prov.reverseShift();
              },
            )
        ),

        Expanded(child: AnyError(
            builder: (context, errCont) => AnimatedOpacity(
              opacity: errCont==0?0:1,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              child: SimpleButton(
                onTap: errCont==0?null:onAlertTap,
                padding: EdgeInsets.all(Dimen.ICON_MARG),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MdiIcons.alertCircleOutline, color: Colors.red),
                    SizedBox(width: Dimen.ICON_MARG),
                    Text('$errCont', style: AppTextStyle(fontWeight: weight.halfBold, color: Colors.red),)
                  ],
                ),
              ),
            )
        )),

        IconButton(
          icon: Icon(MdiIcons.chevronDoubleDown),
          onPressed: (){

            ChordsProvider provider = Provider.of<ChordsProvider>(context, listen: false);

            ChordShifter cs = ChordShifter(provider.chords, 0);
            cs.down();

            String chords = cs.getText(true);
            provider.controller.text = chords;
            provider.chords = chords;

            provider.controller.selection = TextSelection.collapsed(offset: provider.chords.length);
            //parent.onTextChanged?.call(chords, handleErrors(context, isRefren));
          },
        ),

        IconButton(
          icon: Icon(MdiIcons.chevronDoubleUp),
          onPressed: (){

            ChordsProvider provider = Provider.of<ChordsProvider>(context, listen: false);

            ChordShifter cs = ChordShifter(provider.chords, 0);
            cs.up();

            String chords = cs.getText(true);
            provider.controller.text = chords;
            provider.chords = chords;

            provider.controller.selection = TextSelection.collapsed(offset: provider.chords.length);
            //parent.onTextChanged?.call(chords, handleErrors(context, isRefren));
          },
        ),
      ],
    );
  }

}

class ChordPresenceWarning extends StatelessWidget{

  const ChordPresenceWarning();

  @override
  Widget build(BuildContext context) {

    return Consumer<ErrorProvider<ChordsMissingError>>(
      builder: (context, provider, child){

        List<Widget> lineWidgets = [];

        int lines = Provider.of<TextProvider>(context).text.split('\n').length;
        for(int i=0; i<lines; i++){
          ChordsMissingError? error = provider.errorAt(i);
          lineWidgets.add(WarningShade(error==null?background_(context).withOpacity(0):error.color));
        }

        return Column(
            mainAxisSize: MainAxisSize.min,
            children: lineWidgets
        );

      },
    );

  }

}

class WarningShade extends StatelessWidget{

  final Color color;
  const WarningShade(this.color);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(top: 0.5, bottom: 0.5),
      child: AnimatedContainer(
        decoration: BoxDecoration(
            color: color,
            borderRadius: new BorderRadius.all(Radius.circular(4))
        ),
        duration: Duration(milliseconds: 500),
        height: Dimen.TEXT_SIZE_NORMAL + 1,
      ),
    );
  }


}

class TextLengthWarning extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.only(top: TEXT_FIELD_TOP_PADD),
        child: Consumer<ErrorProvider<TextTooLongError>>(builder: (context, provider, child) {

          List<Widget> lineWidgets = [];

          int lines = Provider.of<TextProvider>(context).text.split('\n').length;
          for(int i=0; i<lines; i++){
            TextTooLongError? error = provider.errorAt(i);
            lineWidgets.add(WarningShade(error==null?background_(context).withOpacity(0):error.color));
          }

          return Padding(
            padding: EdgeInsets.only(left: 3),
            child: SizedBox(
              width: Dimen.ICON_MARG+2,
              child: Column(children: lineWidgets),
            ),
          );

        })
    );

  }

}

class LineCount extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.only(top: TEXT_FIELD_TOP_PADD),
        child: Consumer<TextProvider>(builder: (context, textProv, child) {

          return Consumer<ChordsProvider>(
              builder: (context, chordsProv, child) {

                int textLines = textProv.text.split('\n').length;
                int chordsLines = chordsProv.chords.split('\n').length;

                int lines = max(textLines, chordsLines);
                String text = '';
                for(int i=0; i<lines; i++)
                  text += '${i + 1}\n';

                if(text.length>0)
                  text = text.substring(0, text.length-1);

                return Text(
                  text,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: Dimen.TEXT_SIZE_TINY,//initial font size
                      color: hintEnab_(context),
                      height: 1*Dimen.TEXT_SIZE_BIG/ Dimen.TEXT_SIZE_TINY
                  ),
                );
              });

        })
    );

  }

}