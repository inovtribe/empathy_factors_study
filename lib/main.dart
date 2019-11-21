import 'package:factors_empathy_survey/src/app.dart';
import 'package:factors_empathy_survey/src/question.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  //await Store.load(File('${(await getExternalStorageDirectory()).path}/empathy-quotient.csv'));
  
  runApp(App(state: QuestionnaireState(mixedRegistrar)));
}


