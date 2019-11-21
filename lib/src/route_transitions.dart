import 'package:flutter/widgets.dart';

class ScaleRoute extends PageRouteBuilder {
  final RoutePageBuilder pageBuilder;
  ScaleRoute({this.pageBuilder})
      : super(
          pageBuilder: pageBuilder,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
}

class FadeRoute extends PageRouteBuilder {
  final RoutePageBuilder pageBuilder;
  FadeRoute({this.pageBuilder})
      : super(
          pageBuilder: pageBuilder,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: animation,
                child: child,
              ),
        );
}

class PlainRoute extends PageRouteBuilder {
  final RoutePageBuilder pageBuilder;
  PlainRoute({this.pageBuilder})
      : super(
          pageBuilder: pageBuilder,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              child,
        );
}
