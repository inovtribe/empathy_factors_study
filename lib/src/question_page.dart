import 'package:factors_empathy_survey/src/action_page.dart';
import 'package:factors_empathy_survey/src/animated_progress_indicator.dart';
import 'package:factors_empathy_survey/src/animated_widget.dart';
import 'package:factors_empathy_survey/src/home.dart';
import 'package:factors_empathy_survey/src/question.dart';
import 'package:factors_empathy_survey/src/route_transitions.dart';
import 'package:factors_empathy_survey/src/store.dart';
import 'package:factors_empathy_survey/src/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key key}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();

  static void navigate(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PlainRoute(
        pageBuilder: (context, animation, secondaryAnimation) => const QuestionPage(),
      ),
    );
  }
}

class _QuestionPageState extends State<QuestionPage> {
  QuestionnaireState<Question> get state => QuestionnaireState<Question>.of(context);

  String whyNotValid;
  bool get notValid => whyNotValid != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final _state = state;
    final current = _state.current;
    properties.add(IntProperty('current question index', _state.currentIndex));
    properties.add(IntProperty('current question key', current.key));
    final v = Store()[current.key];
    if (current is NumQuestion) {
      properties.add(DoubleProperty('current question answer', v is double ? v : double.tryParse(v)));
    } else if (current is StringQuestion) {
      properties.add(StringProperty('current question answer', v));
    } else if (current is BooleanQuestion) {
      properties.add(FlagProperty('current question answer', value: v is bool ? v : Ternary.parse(v).equivalent));
    } else {
      properties.add(DiagnosticsProperty('current question answer', v));
    }

    properties.add(FlagProperty('is input valid', value: !notValid));
    properties.add(StringProperty('why is input invalid', whyNotValid, ifEmpty: 'Input is valid.'));
  }

  TimeOfDay decodeTime(String string) {
    final splitted = string.split('');
    return TimeOfDay(hour: int.parse(splitted[0]), minute: int.parse(splitted[1]));
  }

  Widget formInput(Question question) {
    final store = Store();
    if (question is SliderQuestion) {
      store[question.key] ??= question.min ?? 0;

      return Slider(
        value: store[question.key],
        onChanged: (v) => store[question.key] = v,
        min: question.min ?? 0,
        max: question.max,
        activeColor: Colors.orangeAccent,
        divisions: question.divisions,
      );
    } else if (question is NumQuestion) {
      store[question.key] ??= '0';
      final controller = TextEditingController(text: store[question.key]);
      return TextField(
        autocorrect: true,
        autofocus: true,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.numberWithOptions(decimal: question.decimal, signed: question.signed),
        onChanged: (_) {
          String txt = controller.value.text.replaceAll(RegExp(r'^\.+|\.+$'), '');
          if (RegExp(r'^(?:\d+|(?:\d*\.\d+))?$').hasMatch(txt)) {
            store[question.key] = (num.tryParse(txt.isNotEmpty ? txt : '0').clamp(question.min, question.max) ?? store[question.key]).toString();
          }
        },
        controller: controller,
        decoration: InputDecoration(hintText: question.hint),
        inputFormatters: [question.decimal ? digitsOnlyOptionalDecimal : WhitelistingTextInputFormatter.digitsOnly],
      );
    } else if (question is StringQuestion) {
      store[question.key] ??= '';
      final controller = TextEditingController(text: store[question.key]);
      return TextField(
        autocorrect: true,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onChanged: (_) => store[question.key] = controller.value.text,
        controller: controller,
        decoration: InputDecoration(hintText: question.hint),
      );
    } else if (question is RadioQuestion) {
      // store[question.key] ??= Ternary.Neutral;
      // if (!(store[question.key] is Ternary)) {
      //   store[question.key] = Ternary.parse(store[question.key]);
      // }
      return question.build(context, setState, store);
    }

    return const Text('You fcked up.');
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = getSafeArea(context, maintainBottomViewPadding: true);
    final question = state.current;
    return ActionPage(
      alignment: MainAxisAlignment.center,
      children: [
        Text(
          question is EQQuestion && question.when == Ternary.Neutral && state.debug ? '|-- ${question.question} --|' : question.question,
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        formInput(question),
        Visibility(
          child: Text(
            whyNotValid ?? '',
            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 18.0),
          ),
          visible: notValid,
        ),
      ],
      bottomBarContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              final store = Store();
              whyNotValid = question.test(store[question.key]);

              if (!notValid) {
                if (state.next == null)
                  HomePage.navigate(context, false);
                else {
                  state.toNext;
                  QuestionPage.navigate(context);
                }
              } else {
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withAlpha(200))]),
              height: 50.0,
              alignment: Alignment.center,
              child: Text(
                'Next',
                style: TextStyle(fontSize: 20.0, color: Colors.orangeAccent),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                color: Colors.orangeAccent,
                width: safeArea.left + safeArea.bottom,
                height: kLinearProgressIndicatorHeight,
              ),
              PageProgressIndicator(
                from: (state.currentIndex) / state.registrar.length,
                to: (state.currentIndex + 1) / state.registrar.length,
                duration: const Duration(seconds: 1),
              ),
              Container(
                color: Colors.orangeAccent,
                width: safeArea.right + safeArea.bottom,
                height: kLinearProgressIndicatorHeight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PageProgressIndicator extends StatefulWidget {
  const PageProgressIndicator({
    @required this.from,
    @required this.to,
    @required this.duration,
    this.action = AnimationAction.forward,
    Key key,
  }) : super(key: key);

  final double from;
  final double to;
  final Duration duration;
  final AnimationAction action;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('from', from));
    properties.add(DoubleProperty('to', to));
    properties.add(DiagnosticsProperty('duration', duration));
    properties.add(EnumProperty<AnimationAction>('action', action));
  }

  @override
  _PageProgressIndicatorState createState() => _PageProgressIndicatorState();
}

class _PageProgressIndicatorState extends State<PageProgressIndicator> with SingleTickerProviderStateMixin, TickedAnimatedWidget<double, PageProgressIndicator>, AutoTickedAnimatedWidget<double, PageProgressIndicator> {
  @override
  double get animationBegin => widget.from;

  @override
  double get animationEnd => widget.to;

  @override
  Duration get animationDuration => widget.duration;

  @override
  AnimationAction get animationAction => widget.action;

  @override
  Widget build(BuildContext context) {
    return FixedProgressIndicator(
      value: animationValue,
      // value: value,
      backgroundColor: Colors.transparent,
      color: Colors.orangeAccent,
      inFlex: true,
      padded: true,
    );
  }
}
