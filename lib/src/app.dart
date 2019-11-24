import 'package:factors_empathy_survey/src/home.dart';
import 'package:factors_empathy_survey/src/question.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: public_member_api_docs
class App extends StatelessWidget {
  //ignore: public_member_api_docs
  const App({@required this.state}) : super();

  /// Holds the app's questionnaire state
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
        theme: ThemeData(
          primaryColor: Colors.orangeAccent,

          hintColor: Colors.grey
        ),
        home: const HomePage(),
      ),
    );
  }
}
