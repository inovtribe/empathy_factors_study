import 'package:flutter_test/flutter_test.dart';
import 'package:factors_empathy_survey/src/app.dart';
import 'package:factors_empathy_survey/src/question.dart';

void main() {
  testWidgets('Home page works', (WidgetTester tester) async {
    final state = QuestionnaireState(mixedRegistrar);
    // Build our app and trigger a frame.
    await tester.pumpWidget(App(state: state));

    // Verify that our counter starts at 0.
    expect(find.text('Welcome.'), findsOneWidget);
    expect(find.text('Thank you for participating in our survey.'), findsNothing);

    //TODO(mpfaff): Figure out how to wait for FutureBuilder.

    expect(find.text('Start'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.text('Start'));
    // await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.text('<some question>'), findsNothing);
  });
}
