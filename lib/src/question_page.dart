import 'package:factors_empathy_survey/src/action_page.dart';
import 'package:factors_empathy_survey/src/animated_progress_indicator.dart';
import 'package:factors_empathy_survey/src/animated_widget.dart';
import 'package:factors_empathy_survey/src/home.dart';
import 'package:factors_empathy_survey/src/question.dart';
import 'package:factors_empathy_survey/src/radio_button_group.dart';
import 'package:factors_empathy_survey/src/route_transitions.dart';
import 'package:factors_empathy_survey/src/store.dart';
import 'package:factors_empathy_survey/src/util.dart';
import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key key}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();

  static void navigate(BuildContext context) {
    Navigator.of(context).push(
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

  dynamic tmp;
  /// These lines should be used for debugging the value of `tmp`.
  // dynamic _tmp;
  // dynamic get tmp => _tmp;
  // set tmp(dynamic newTmp) => _tmp = newTmp;

  set tmpC(dynamic newTmp) {
    whyNotValid = state.current.test(newTmp);
    tmp = newTmp;
  }

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
      if (!(tmp is double)) {
        // TODO(mpfaff): Possibly remove store logic
        tmp = store[question.key] ?? question.min ?? 0;
      }

      return Slider(
        value: tmp,
        onChanged: (v) => tmp = v,
        min: question.min ?? 0,
        max: question.max,
        activeColor: Colors.orangeAccent,
        divisions: question.divisions,
      );
    }
    else if (question is NumQuestion) {
      if (!(tmp is String)) {
        // TODO(mpfaff): Possibly remove store logic
        tmp = store[question.key] ?? '0';
      }
      final controller = TextEditingController(text: tmp);
      return TextField(
        autocorrect: true,
        autofocus: true,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.numberWithOptions(decimal: question.decimal, signed: question.signed),
        onChanged: (_) => tmp = controller.value.text,
        controller: controller,
        decoration: InputDecoration(hintText: question.hint),
      );
    } else if (question is StringQuestion) {
      if (!(tmp is String)) {
        // TODO(mpfaff): Possibly remove store logic
        tmp = store[question.key] ?? '';
      }
      final controller = TextEditingController(text: tmp);
      return TextField(
        autocorrect: true,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onChanged: (_) => tmp = controller.value.text,
        controller: controller,
        decoration: InputDecoration(hintText: question.hint),
      );
    } else if (question is BooleanQuestion) {
      if (!(tmp is Ternary)) {
        // TODO(mpfaff): Possibly remove store logic
        tmp = Ternary.parse(store[question.key]) ?? Ternary.Neutral;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialButton(
            color: tmp == Ternary.True ? Colors.orangeAccent : Colors.white,
            elevation: 4,
            child: Text('True', style: TextStyle(fontSize: 14)),
            onPressed: () => setState(() => tmp = Ternary.True),
          ),
          MaterialButton(
            color: tmp == Ternary.False ? Colors.orangeAccent : Colors.white,
            elevation: 4,
            child: Text('False', style: TextStyle(fontSize: 14)),
            onPressed: () => setState(() => tmp = Ternary.False),
          ),
        ],
      );
    } else if (question is EQQuestion) {
      return RadioButtonGroup<Response>(
            options: Response.agreementSet,
            orientation: Axis.horizontal,
            onSelected: (value, label) => setState(() => tmp = value),
            itemBuilder: (context, value, label, disabled, onSelected) => RadioBoxButton(label: label, value: value, isSelected: value == tmp, onSelected: onSelected),
          );
    }

    return const Text('You fcked up.');
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = getSafeArea(context, maintainBottomViewPadding: true);
    final current = state.current;
    return ActionPage(
      alignment: MainAxisAlignment.center,
      children: [
        Text(
          current is EQQuestion && current.when == Ternary.Neutral && state.debug ? '|-- ${current.question} --|' : current.question,
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        formInput(current),
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
              whyNotValid = current.test(tmp);

              if (!notValid) {
                if (current is EQQuestion) {
                  current.add(tmp);
                } else {
                  store[current.key] = tmp;
                }

                if (state.next != null) {
                  state.toNext;
                  QuestionPage.navigate(context);
                } else {
                  store.save().then((_) {
                    HomePage.navigate(context, false);
                  });
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

class RadioBoxButton<T> extends StatelessWidget {
  final OnRadioButtonSelected<T> onSelected;

  const RadioBoxButton({
    @required this.value,
    @required this.label,
    @required this.isSelected,
    @required this.onSelected,
    Key key,
  })  : assert(label != null, 'label must not be null'),
        assert(value != null, 'value must not be null'),
        super(key: key);

  final T value;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(value, label),
        enableFeedback: true,
        splashColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.orangeAccent : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
          child: Text(
            label,
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
            ),
          ),
        ),
      ),
    );
  }
}
