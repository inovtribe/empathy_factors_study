import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum AnimationAction {
  Forward,
  Reverse,
  Repeat,
  ReverseRepeat,
}

@optionalTypeArgs
mixin TickedAnimatedWidget<T, S extends StatefulWidget> on State<S>, TickerProvider {
  @protected
  Duration get animationDuration;
  @protected
  T get animationBegin;
  @protected
  T get animationEnd;
  @protected
  AnimationAction get animationAction;

  @protected
  AnimationController controller;

  @protected
  Animation<T> animation;

  @protected
  T get animationValue => animation?.value ?? animationBegin;

  /// Initializes the animation. If you override the initState method, be sure
  /// to call this manually.
  @protected
  void initStateAnimation() {
    controller = AnimationController(duration: animationDuration, vsync: this);
    animation = Tween(begin: animationBegin, end: animationEnd).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    switch (animationAction) {
      case AnimationAction.Forward:
        controller.forward();
        break;
      case AnimationAction.Reverse:
        controller.reverse();
        break;
      case AnimationAction.Repeat:
        controller.repeat();
        break;
      case AnimationAction.ReverseRepeat:
        controller.repeat(reverse: true);
        break;
    }
  }

  /// Disposes of the animation. If you override the initState method, be sure
  /// to call this manually.
  @protected
  void disposeAnimation() {
    controller.stop();
  }
}

@optionalTypeArgs
mixin AutoTickedAnimatedWidget<T, S extends StatefulWidget> on TickedAnimatedWidget<T, S> {
  @override
  void initState() {
    super.initState();
    initStateAnimation();
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }
}
