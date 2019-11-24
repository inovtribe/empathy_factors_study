import 'package:factors_empathy_survey/src/action_page.dart';
import 'package:factors_empathy_survey/src/animated_progress_indicator.dart';
import 'package:factors_empathy_survey/src/animated_widget.dart';
import 'package:factors_empathy_survey/src/home.dart';
import 'package:factors_empathy_survey/src/question.dart';
import 'package:factors_empathy_survey/src/route_transitions.dart';
import 'package:factors_empathy_survey/src/store.dart';
import 'package:factors_empathy_survey/src/util.dart';
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

class _QuestionPageState extends State<QuestionPage> with SingleTickerProviderStateMixin, TickedAnimatedWidget<double, QuestionPage> {
  QuestionnaireState<Question> get state => QuestionnaireState<Question>.of(context);

  @override
  AnimationAction get animationAction => AnimationAction.Forward;

  @override
  double get animationBegin => (state.currentIndex) / state.registrar.length;

  @override
  Duration get animationDuration => const Duration(seconds: 1);

  @override
  double get animationEnd => (state.currentIndex + 1) / state.registrar.length;

  String whyNotValid;
  bool get notValid => whyNotValid != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(initStateAnimation));
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
        onChanged: (_) => store[question.key] = controller.value.text,
        controller: controller,
        decoration: InputDecoration(hintText: question.hint),
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly, ClampedTextInputFormatter(question.min, question.max)],
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
              FixedProgressIndicator(
                value: animationValue,
                // value: value,
                backgroundColor: Colors.transparent,
                color: Colors.orangeAccent,
                inFlex: true,
                padded: true,
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
