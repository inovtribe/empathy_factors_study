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
import 'package:grouped_buttons/grouped_buttons.dart' show GroupedButtonsOrientation;

class QuestionPage extends StatefulWidget {
  QuestionPage({Key key}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();

  static void navigate(BuildContext context) {
    Navigator.of(context).push(
      PlainRoute(
        pageBuilder: (context, animation, secondaryAnimation) => QuestionPage(),
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

  String whyFckedUp;
  bool get fckedUp => whyFckedUp != null;

  dynamic _tmp;
  dynamic get tmp => _tmp;
  set tmp(dynamic newTmp) => _tmp = newTmp;

  set tmpC(dynamic newTmp) {
    whyFckedUp = state.current.test(newTmp);
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

  Widget formInput(InputQuestion question) {
    final store = Store();
    switch (question.type) {
      case InputType.String:
        //TODO(mpfaff): Possibly remove store logic
        tmp ??= store[question.key] ?? '';
        final controller = TextEditingController(text: tmp);
        return TextField(
          autocorrect: true,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => tmp = controller.value.text,
          controller: controller,
        );
      case InputType.Int:
        //TODO(mpfaff): Possibly remove store logic
        tmp ??= store[question.key] ?? '0';
        final controller = TextEditingController(text: tmp);
        return TextField(
          autocorrect: true,
          autofocus: true,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          onChanged: (_) => tmp = controller.value.text,
          controller: controller,
        );
      case InputType.Double:
        //TODO(mpfaff): Possibly remove store logic
        if (!(tmp is String)) {
          tmp = store[question.key] ?? '0';
        }
        final controller = TextEditingController(text: tmp);
        return TextField(
          autocorrect: true,
          autofocus: true,
          textInputAction: TextInputAction.done,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => tmp = controller.value.text,
          controller: controller,
        );
      case InputType.Boolean:
        tmp ??= Ternary.Neutral;
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
          current is EQQuestion && current.when == When.Distraction && state.debug ? '|-- ${current.question} --|' : current.question,
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        if (current is EQQuestion)
          RadioButtonGroup<Response>(
            options: Response.agreementSet,
            orientation: GroupedButtonsOrientation.HORIZONTAL,
            onSelected: (value, label) => setState(() => tmp = value),
            itemBuilder: (context, value, label, disabled, onSelected) => RadioBoxButton(label: label, value: value, isSelected: value == tmp, length: 4, onSelected: onSelected),
          ),
        if (current is InputQuestion) formInput(current),
        Visibility(
          child: Text(
            whyFckedUp ?? '',
            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 18.0),
          ),
          visible: fckedUp,
        ),
      ],
      bottomBarContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              final store = Store();
              whyFckedUp = current.test(tmp);

              if (!fckedUp) {
                if (current is EQQuestion) {
                  switch (current.when) {
                    case When.Agree:
                      if (tmp == Response.StronglyAgree)
                        store.add(2);
                      else if (tmp == Response.SlightlyAgree) store.add(1);
                      break;
                    case When.Distraction:
                      break;
                    case When.Disagree:
                      if (tmp == Response.StronglyDisagree)
                        store.add(2);
                      else if (tmp == Response.SlightlyDisagree) store.add(1);
                      break;
                  }
                } else if (current is InputQuestion) {
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
    Key key,
    @required this.value,
    @required this.label,
    @required this.isSelected,
    @required this.length,
    @required this.onSelected,
  })  : assert(label != null, 'label must not be null'),
        assert(value != null, 'value must not be null'),
        super(key: key);

  final T value;
  final String label;
  final bool isSelected;
  final int length;

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
