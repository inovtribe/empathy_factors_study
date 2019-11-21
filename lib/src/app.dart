import 'package:factors_empathy_survey/src/home.dart';
import 'package:factors_empathy_survey/src/question.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({@required this.state}) : super();

  final QuestionnaireState<Question> state;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<QuestionnaireState<Question>>.value(
          value: state,
          updateShouldNotify: (_, __) => false,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(primaryColor: Colors.orangeAccent),
        home: const HomePage(),
      ),
    );
  }
}
