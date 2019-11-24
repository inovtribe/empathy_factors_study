import 'dart:io';

import 'package:factors_empathy_survey/src/action_page.dart';
import 'package:factors_empathy_survey/src/animated_progress_indicator.dart';
import 'package:factors_empathy_survey/src/animated_widget.dart';
import 'package:factors_empathy_survey/src/question.dart';
import 'package:factors_empathy_survey/src/question_page.dart';
import 'package:factors_empathy_survey/src/route_transitions.dart';
import 'package:factors_empathy_survey/src/store.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key, this.start = true}) : super(key: key);

  static void navigate(BuildContext context, bool start) {
    Navigator.of(context).pushReplacement(
      PlainRoute(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(start: start),
      ),
    );
  }

  final bool start;

  QuestionnaireState<Question> state(BuildContext context) => QuestionnaireState<Question>.of(context);

  Future<bool> initialize() async {
    // return Future.delayed(const Duration(seconds: 1), () {
    //   return true;
    // });
    if (start) {
      await Store.load(File('${(await getExternalStorageDirectory()).path}/empathy-quotient.csv'));
    } else {
      await Store().save();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ActionPage(
      children: [
        InkWell(
          onTap: () {
            state(context).debugCount++;
          },
          child: Text(
            start ? 'Welcome.' : 'Thank you for participating in our survey.',
            style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 30.0),
            softWrap: true,
          ),
        )
      ],
      bottomBarContent: GestureDetector(
        onTap: () {
          final store = Store();
          store.start(DateTime.now());
          if (!start) {
            state(context).currentIndex = 0;
          }
          QuestionPage.navigate(context);
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withAlpha(200))]),
          height: 50.0,
          alignment: Alignment.center,
          child: FutureBuilder<bool>(
              future: initialize(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    start ? 'Start' : 'Do Another',
                    style: TextStyle(fontSize: 20.0, color: Colors.orangeAccent),
                  );
                } else {
                  return const MicrosoftProgressBar();
                }
              }),
        ),
      ),
    );
  }
}

class MicrosoftProgressBar extends StatefulWidget {
  const MicrosoftProgressBar({
    Key key,
  }) : super(key: key);

  @override
  _MicrosoftProgressBarState createState() => _MicrosoftProgressBarState();
}

class _MicrosoftProgressBarState extends State<MicrosoftProgressBar> with SingleTickerProviderStateMixin, TickedAnimatedWidget<double, MicrosoftProgressBar> {
  @override
  Widget build(BuildContext context) {
    return FixedProgressIndicator(
      value: animationValue,
      backgroundColor: Colors.transparent,
      color: Colors.orangeAccent,
    );
  }

  @override
  final AnimationAction animationAction = AnimationAction.Repeat;

  @override
  final double animationBegin = 0;

  @override
  final Duration animationDuration = const Duration(seconds: 5);

  @override
  final double animationEnd = 1;
}
