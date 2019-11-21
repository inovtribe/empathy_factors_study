import 'package:flutter/material.dart';

// import 'package:factors_empathy_survey/src/bottom_app_bar.dart';

class ActionPage extends StatelessWidget {
  const ActionPage({@required this.children, this.actionLabel, this.action, Key key, this.padding = const EdgeInsets.symmetric(vertical: 80.0, horizontal: 30), this.alignment = MainAxisAlignment.start, this.bottomBarContent})
      : assert(alignment != null, 'alignment must not be null'),
        super(key: key);

  final List<Widget> children;
  final VoidCallback action;
  final String actionLabel;
  final EdgeInsets padding;
  final MainAxisAlignment alignment;
  final Widget bottomBarContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: padding,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: alignment,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
              ),
            ),
            BottomAppBar(
              child: bottomBarContent ??
                  GestureDetector(
                    onTap: action ?? () {},
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withAlpha(200))]),
                      constraints: BoxConstraints(minWidth: double.infinity, minHeight: double.infinity),
                      alignment: Alignment.center,
                      child: Text(
                        actionLabel ?? 'You Lazy Ass',
                        style: TextStyle(fontSize: 20.0, color: Colors.orangeAccent),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
